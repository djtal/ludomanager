require File.dirname(__FILE__) + '/../test_helper'

context "New Games Account" do
  fixtures :account_games, :accounts, :games
  
  specify "should have a game" do
    assert_invalid clean_game_account, :game_id, nil
    assert_equal account_games(:one).game, games(:battlelore)
  end
  
  specify "should have an account" do
    assert_invalid clean_game_account, :account_id, nil
    assert_equal account_games(:one).account, accounts(:quentin)
  end
  
  specify "should have only one copy of game per account" do
    assert clean_game_account.save
    assert !clean_game_account.save
  end
  
  specify "last should give last buyed game" do
    
  end
  
  
  
  private
  
  def clean_game_account(overrides = {})
    opts = {
      :account_id => 1,
      :game_id => 1
    }.merge(overrides)
    AccountGame.new(opts)
  end
end