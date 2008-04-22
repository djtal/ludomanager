require File.dirname(__FILE__) + '/../test_helper'
require 'account_games_controller'

# Re-raise errors caught by the controller.
class AccountGamesController; def rescue_action(e) raise e end; end


context "Logged User can have a list of games" do
  fixtures :account_games, :accounts, :games

  def setup
    @controller = AccountGamesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as(:aaron) 
  end

  specify "can acces his own game list" do
    get :index
    assert_response :success
    assert assigns(:account_games)
  end
  
  specify "can add game to his list" do
    assert_difference "AccountGame.count" do
      post :create, :account_game => {:game_id => games(:coloreto).id}
    end
    a = accounts(:aaron).account_games.find_by_game_id(games(:coloreto).id)
    assert_not_nil a
    assert_equal games(:coloreto).price, a.price
    assert_equal Time.now.to_date, a.transdate.to_date
    assert_equal 1, accounts(:aaron).account_games.size
    assert_redirected_to account_games_path
  end
  
  specify "can delete a game from his list" do
    assert_difference "AccountGame.count", -1 do
      delete :destroy, :id => 1
    end
    assert_redirected_to account_games_path
  end
   
end

context "Account Game list for non logged user" do
  fixtures :account_games, :accounts, :games

  def setup
    @controller = AccountGamesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as(nil) 
  end
  
  specify "cannot acces list" do
    get :index
    assert_response :redirect
    assert_redirected_to login_path
  end
  
  specify "cannot add game to a list" do
    assert_no_difference "AccountGame.count" do
      post :create, :game_id => games(:coloreto).id
    end
    assert_response :redirect
    assert_redirected_to login_path
  end
  
  specify "cannot delete a game from a list" do
    assert_no_difference "AccountGame.count "do
      delete :destroy, :id => 1
    end
    assert_response :redirect
    assert_redirected_to login_path
  end
  
  
  
end
