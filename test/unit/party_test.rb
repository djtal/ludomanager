require File.dirname(__FILE__) + '/../test_helper'

context "Party Creation" do
  fixtures :all
  
  specify "game should be mandatory" do
    assert_invalid clean_party, :game_id, nil
  end
  
  specify "should have a game" do
    assert clean_party.respond_to?("game")
    assert_equal games(:ever_played), parties(:first).game
  end
  
  specify "have an mandatory account" do
    assert_invalid clean_party, :account_id, nil
    assert_equal accounts(:aaron).id, parties(:second).account_id
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