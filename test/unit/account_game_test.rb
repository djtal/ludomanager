require File.dirname(__FILE__) + '/../test_helper'

class AccountGameTest < ActiveSupport::TestCase
  fixtures :all
  
  
  def test_can_own_only_once_a_game
    assert clean_game_account.save
    assert !clean_game_account.save
  end
  
  def test_replace_should_replace_old_game_witout_change_to_other_att
    assert AccountGame.replace_game(games(:battlelore), games(:agricola))
    assert_equal 0, AccountGame.count(:conditions => {:game_id => games(:battlelore).id})
    assert_equal 1, AccountGame.count(:conditions => {:game_id => games(:agricola).id})
  end
  
  def test_parties_count
    assert_equal 2, account_games(:quention_coloreto).parties_played_count
  end
  
  def test_newly_ac_games_should_setup_parties_cache_according_plarties_played
    ac = accounts(:quentin).account_games.build(:game_id => games(:funkenshlag).id)
    assert ac.save
    assert_equal 2, ac.parties_count
  end
  
  private
  
  def clean_game_account(overrides = {})
    opts = {
      :account_id => 1,
      :game_id => games(:coloreto).id,
      :price => 10,
      :origin => "a shop somewhere"
    }.merge(overrides)
    AccountGame.new(opts)
  end
end

