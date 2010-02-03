require 'test_helper'

class PartyTest < ActiveSupport::TestCase
  
  context "a Party" do
    should_validate_presence_of :game_id, :account_id
    should_belong_to :game
    should_belong_to :account
    should_have_many :players, :dependent => :destroy
  end
  
  context "A user playing a game he own" do
    setup do
      @game = Factory.create(:game)
      @party = Factory.build(:party, :account => accounts(:quentin), :game => @game)
      Time.zone = 'Paris'
      accounts(:quentin).games << @game
    end
    
    should "update account parties cache when party is saved" do
      assert_difference 'accounts(:quentin).account_games.find_by_game_id(@game.id).parties_count' do
        @party.save
      end
    end
    
    should "update last played date" do
      @party.created_at = 1.day.ago
      @party.save
      assert_equal 1.day.ago.to_date, accounts(:quentin).account_games.find_by_game_id(@game.id).last_play
    end
    
    should "update account parties cache when party is  destroyed" do
      @party.save
      assert_difference 'accounts(:quentin).account_games.find_by_game_id(@game.id).parties_count', -1 do
        @party.destroy
      end
    end
  end

  context "A user playing a game he doesnt own" do
    setup do
      @game = Factory.create(:game)
      @party = Factory.build(:party, :account => accounts(:quentin), :game => @game)
    end
    
    should "do nothing party is saved" do
      assert_nothing_raised do
        @party.save
      end
    end
    
    should "do nothing party is destroyed" do
      @party.save
      assert_nothing_raised do
        @party.destroy
      end
    end
    
  end
  
  context "Parties yearly breakdown" do
  
    should "return an hash" do
      assert_equal ActiveSupport::OrderedHash, Party.yearly_breakdown.class
    end
    
    should "return empty hash if no date given" do
       assert_equal ActiveSupport::OrderedHash, Party.yearly_breakdown(nil, nil).class
    end
    
    should "raise an error if fromYear > toYear" do
      assert_raise(Exception) { Party.yearly_breakdown(2009, 2006)}
    end
    
    should "return a an array for each month of each year between from and to year" do
      result = Party.yearly_breakdown(2008, 2008)
      assert_equal Array, result[2008].class
      assert_equal 12, result[2008].size
    end
    
  end
  
  context "Party" do
    should "replace parties of one game by another" do
      account = Factory.create(:account)
      3.times do
        Factory.create(:party, :account => account, :game => games(:coloreto_ext))
      end
      Party.replace_game(games(:coloreto_ext), games(:agricola))
      assert_equal 0, Party.count(:all, :conditions => {:game_id => games(:coloreto_ext).id})
      assert_equal 3, Party.count(:all, :conditions => {:game_id => games(:agricola).id})
    end
  end
  
  context "previous_play_date_from" do
    setup do
      @game  = Factory(:game)
      @account = Factory.create(:account)
    end
    
    should "return nil if no party is found" do
      assert_nil @account.parties.previous_play_date_from
    end
    
    should "find last party date before given date if date is supplied" do
      Factory.create(:party, :account => @account, :game => @game, :created_at => 1.month.ago.beginning_of_month)
      Factory.create(:party, :account => @account, :game => @game, :created_at => 3.month.ago.beginning_of_month)
      assert_equal 3.month.ago.beginning_of_month, @account.parties.previous_play_date_from(2.month.ago)
    end
    
    should "use curent date if no one is supplied" do
      played_date = 1.month.ago.beginning_of_month
      Factory.create(:party, :account => @account, :game => @game, :created_at => played_date)
      assert_equal played_date, @account.parties.previous_play_date_from
    end
  end
  
  context "next_play_date_from" do
    setup do
      @game  = Factory(:game)
      @account = Factory.create(:account)
    end
    
    should "return nil if no party is found" do
      assert_nil @account.parties.next_play_date_from
    end
    
    should "find next party date after given date if date is supplied" do
      Factory.create(:party, :account => @account, :game => @game, :created_at => 1.month.from_now.beginning_of_month)
      Factory.create(:party, :account => @account, :game => @game, :created_at => 3.month.from_now.beginning_of_month)
      Factory.create(:party, :account => @account, :game => @game, :created_at => 4.month.from_now.beginning_of_month)
      assert_equal 3.month.from_now.beginning_of_month, @account.parties.next_play_date_from(2.month.from_now)
    end
  end
  
  context "searching parties by date" do
    setup do
      @game  = Factory(:game)
      @account = Factory.create(:account)
      Time.zone = 'Paris'
      @date = Time.zone.parse("02/01/2009")
      Factory.create(:party, :account => @account, :game => @game, :created_at => @date)
      Factory.create(:party, :account => @account, :game => @game, :created_at => @date)
      Factory.create(:party, :account => @account, :game => @game, :created_at => @date)
      Factory.create(:party, :account => @account, :game => @game, :created_at => 1.month.from_now.beginning_of_month)
      Factory.create(:party, :account => @account, :game => @game, :created_at => 3.month.from_now.beginning_of_month)
      Factory.create(:party, :account => @account, :game => @game, :created_at => 4.month.from_now.beginning_of_month)
    end
    
    should "return only the partie for given day" do
      assert_equal 3, @account.parties.for_day(@date).size
    end
  end
  
  
  
  def test_allow_more_player
    assert !parties(:party_full_player).allow_more_players?
    assert parties(:party_empty_player).allow_more_players?
  end

end