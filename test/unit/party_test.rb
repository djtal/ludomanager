require File.dirname(__FILE__) + '/../test_helper'

class PartyTest < Test::Unit::TestCase
  fixtures :all
  
  def test_game_should_be_mandatory
    assert_invalid clean_party, :game_id, nil
  end
  
  
  def test_account_is_mandatory 
    assert_invalid clean_party, :account_id, nil
    assert_equal accounts(:aaron).id, parties(:second).account_id
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
  

  
  private
  
  def clean_party(overrides = {})
    opts = {
      :game_id => games(:coloreto).id,
      :account_id => accounts(:quentin).id
    }.merge(overrides)
    Party.new(opts)
  end
end