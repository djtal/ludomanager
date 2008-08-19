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
  
  
  def test_allow_more_player
    assert !parties(:party_full_player).allow_more_players?
    assert parties(:party_empty_player).allow_more_players?
  end
  
  def test_replace_should_replace_all_old_game_occurance_by_new_game
    3.times do
      clean_party(:game_id => games(:coloreto_ext).id).save
    end
    Party.replace(games(:coloreto_ext), games(:agricola))
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