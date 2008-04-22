require File.dirname(__FILE__) + '/../test_helper'
require 'games_controller'

# Re-raise errors caught by the controller.
class GamesController; def rescue_action(e) raise e end; end

context "Game for logged user" do
  fixtures :games, :accounts, :parties

  def setup
    @controller = GamesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as(:quentin)
  end

  specify "can delete game without any party" do
    assert_difference "Game.count", -1 do
      delete :destroy, :id => 1
    end    
    assert_redirected_to games_path
  end
  
  specify "cannot delete a game with at least one party played" do
    assert_equal games(:ever_played), parties(:first).game
    assert games(:ever_played).parties.size > 0
    assert_no_difference "Game.count" do
      delete :destroy, :id => games(:ever_played).id
    end    
    assert_redirected_to games_path
    
  end

end

context "Games for non logged user" do
  fixtures :games

  def setup
    @controller = GamesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as(nil)
  end
  
  specify "can acces new game form" do
    get :new
    assert_response :success
  end
  
  specify "can acces games list" do
    get :index
    assert_response :success
    assert assigns(:games)
  end
  
  specify "can create game" do
    assert_difference "Game.count" do
      post :create, {:game => {:name => "test", :difficulty => 1, :min_player => 2, :max_player => 6 },
                      :game_photo => {:uploaded_data => ""}}
    end
    assert_redirected_to game_path(assigns(:game))
  end
  
  specify "can show a game spec" do
    get :show, :id => 1
    assert_response :success
  end
  
  specify "can edit game" do
    get :edit, :id => 1
    assert_response :success
  end
    
  specify "can update game" do
    put :update, {:id => 1 ,:game => { :name => "test" }, :game_photo => {:uploaded_data => ""}}
    assert_redirected_to game_path(assigns(:game))
    assert_equal "test", Game.find(1).name
  end
  
  specify "cannot destroy game" do
    assert_no_difference "Game.count" do
      delete :destroy, :id => 1
    end
    assert_response :redirect
    assert_redirected_to login_path
  end
  
end
