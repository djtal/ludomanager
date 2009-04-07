require File.dirname(__FILE__) + '/../test_helper'

class PartyTest < ActiveSupport::TestCase
  
  context "a Party" do
    should_validate_presence_of :game_id, :account_id
    should_belong_to :game
    should_belong_to :account
    should_have_many :players, :dependent => :destroy
  end
  
  
  context "Parties yearly breakdown" do
  
    should "return an hash" do
      assert_equal Hash, Party.yearly_breakdown.class
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

  def test_should_update_parties_cache_if_own_played_game
    assert_equal 0, accounts(:quentin).account_games.first.parties_count
    p = clean_party(:game_id => games(:battlelore).id)
    assert p.save
    assert_equal 1, accounts(:quentin).account_games.find_by_game_id(games(:battlelore).id).parties_count
    p.destroy
    assert_equal 0, accounts(:quentin).account_games.find_by_game_id(games(:battlelore).id).parties_count
  
    assert_nothing_raised do
      p = clean_party(:game_id => games(:coloreto).id)
      assert p.save
    end
  end
  
  
  def test_allow_more_player
    assert !parties(:party_full_player).allow_more_players?
    assert parties(:party_empty_player).allow_more_players?
  end
  
  
  def test_replace_should_replace_all_old_game_occurance_by_new_game
    3.times do
      clean_party(:game_id => games(:coloreto_ext).id).save
    end
    Party.replace_game(games(:coloreto_ext), games(:agricola))
    assert_equal 0, Party.count(:all, :conditions => {:game_id => games(:coloreto_ext).id})
    assert_equal 3, Party.count(:all, :conditions => {:game_id => games(:agricola).id})
  end

  
  private
  
  def clean_party(overrides = {})
    opts = {
      :game_id => games(:coloreto).id,
      :account_id => accounts(:quentin).id
    }.merge(overrides)
    Party.new(opts)
  end
end