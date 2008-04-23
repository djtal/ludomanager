require File.dirname(__FILE__) + '/../test_helper'
require 'games_controller'

# Re-raise errors caught by the controller.
class GamesController; def rescue_action(e) raise e end; end

class GamesControllerTest < Test::Unit::TestCase
  fixtures :games, :accounts, :parties

  def setup
    @controller = GamesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_logged_user_can_delete
    login_as(:quentin)
    assert_difference "Game.count", -1 do
      delete :destroy, :id => 1
    end    
    assert_redirected_to games_path
  end
  
  def test_logged_user_cannot_delete_game_with_parties
    login_as(:quentin)
    assert_equal games(:ever_played), parties(:first).game
    assert games(:ever_played).parties.size > 0
    assert_no_difference "Game.count" do
      delete :destroy, :id => games(:ever_played).id
    end    
    assert_redirected_to games_path
  end
  
  def test_no_logged_user_cannot_delete_game
    assert_no_difference "Game.count"do
      delete :destroy, :id => 1
    end    
    assert_redirected_to login_path
  end
  
end
