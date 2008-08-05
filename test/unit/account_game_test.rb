require File.dirname(__FILE__) + '/../test_helper'

class AccountGameTest < Test::Unit::TestCase
  fixtures :account_games, :accounts, :games
  
  
  def test_can_own_only_once_a_game
    assert clean_game_account.save
    assert !clean_game_account.save
  end
  
  def test_should_take_price_from_game_if_not_set
    a = clean_game_account({:price => nil})
    assert_equal nil, a.price
    assert a.save
  end
  
  def test_should_set_date_to_now_if_not_set
    a = clean_game_account({:price => nil})
    assert_equal nil, a.transdate
    assert a.save
    assert_equal Time.now.to_date, a.transdate
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

