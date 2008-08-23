require File.dirname(__FILE__) + '/../test_helper'

class AccountGameTest < Test::Unit::TestCase
  fixtures :all
  
  
  def test_can_own_only_once_a_game
    assert clean_game_account.save
    assert !clean_game_account.save
  end
  
  def test_should_take_price_from_game_if_not_set
    a = clean_game_account({:price => nil})
    assert_equal nil, a.price
    assert a.save
  end
  
  def test_replace_should_replace_old_game_witout_change_to_other_att
    assert AccountGame.replace_game(games(:battlelore), games(:agricola))
    assert_equal 0, AccountGame.count(:conditions => {:game_id => games(:battlelore).id})
    assert_equal 1, AccountGame.count(:conditions => {:game_id => games(:agricola).id})
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

