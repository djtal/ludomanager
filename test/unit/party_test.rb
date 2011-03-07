require 'test_helper'

class PartyTest < ActiveSupport::TestCase
  
  context "Party" do
    should_validate_presence_of :game_id, :account_id
    should_belong_to :game
    should_belong_to :account
    
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
  
  context "getting date range for played parties" do
    setup do
      
    end

    should "description" do
      
    end
  end
  
  
  context "Parties yearly breakdown" do
    setup do
      @account = Factory.create(:account)
      @g1 = Factory.create(:game, :name => "6 Nimt")
      @g2 = Factory.create(:game, :name => "11 Nimt")
      10.times{Factory.create(:party, :game => @g1, :account => @account, :created_at => DateTime.civil(2010, 1))}
      12.times{Factory.create(:party, :game => @g2, :account => @account, :created_at => DateTime.civil(2010, 3))}
    end
    
    should "return an hash" do
      assert_equal ActiveSupport::OrderedHash, Party.yearly_breakdown.class
    end
    
    should "return empty hash if no date given" do
       assert_equal ActiveSupport::OrderedHash, Party.yearly_breakdown(:from => nil, :to => nil).class
    end
    
    should "raise an error if fromYear > toYear" do
      assert_raise(InvalidDateRange) { Party.yearly_breakdown(:from => 2009, :to => 2006)}
    end
    
    should "return a an array for each month of each year between from and to year" do
      result = Party.yearly_breakdown(:from => 2008, :to => 2008)
      assert_equal Array, result[2008].class
      assert_equal 12, result[2008].size
    end
    
    should  "count the number of played parties for each month in given years range" do      
      breakdown = @account.parties.yearly_breakdown(:from => 2010, :to => 2010)
      assert_equal 10, breakdown[2010][0]
      assert_equal 12, breakdown[2010][2]
    end
    
    should "filter by game_id if :game optiosn is supplied" do
      breakdown = @account.parties.yearly_breakdown(:game => @g2, :from => 2010, :to => 2010)
      assert_equal 0, breakdown[2010][0]
      assert_equal 12, breakdown[2010][2]
    end
    
  end
  
  context "player breadonw" do
    setup do
      @account = Factory.create(:account)
      @g1 = Factory.create(:game, :name => "6 Nimt")
      @g2 = Factory(:game, :name => "11 Nimt")
      (2..10).each do |p|
        10.times{Factory(:party, :game => @g1, :nb_player => p, :account => @account)}
      end
    end

    should "return a new OrderedHash if game is not played" do
      result = @account.parties.player_breakdown(:game => @g2)
      assert_equal ActiveSupport::OrderedHash.new, result
    end
    
    should "return a hash with nbPlayer as key and parties count as value" do
      result = @account.parties.player_breakdown(:game => @g1)
      assert_equal [2,3,4,5,6,7,8,9,10], result.keys
      assert_equal [10,10,10,10,10,10,10,10,10], result.values
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
  
  context "searching parties" do
    context "by date" do
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
    
    context "by game" do
      setup do
        @user = Factory.create(:account)
        @game_a = Factory.create(:game, :name => "asterodys")
        @game_b = Factory.create(:game, :name => "battlestar galactica")
        @game_c = Factory.create(:game, :name => "castle panic")
        [@game_a, @game_b, @game_c].each do |game|
          (1..10).each do
            Factory.create(:party, :game => game, :account => @user)
          end  
        end
      end
      
      should "return all played game if no filter provided" do
        assert_equal 3, @user.parties.by_game.keys.size
      end
      should "return all played game if no filter provided" do
        assert_equal 1, @user.parties.by_game("a").keys.size
        assert_equal @game_a, @user.parties.by_game("a").keys.first
      end
    end
  end

end