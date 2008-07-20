require File.dirname(__FILE__) + '/../test_helper'
require 'games_controller'

# Re-raise errors caught by the controller.
class GamesController; def rescue_action(e) raise e end; end

class GamesControllerTest < Test::Unit::TestCase
  fixtures :all

  def setup
    @controller = GamesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_logged_user_can_delete
    login_as(:quentin)
    assert_difference "Game.count", -1 do
      delete :destroy, :id => games(:coloreto).id
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
  
  def test_create_register_authors
    form = {
      "game"=>{"name"=>"6 qui prend", "publish_year"=>"", "url"=>"", "description"=>"balh", "editor"=>"Amigo", "min_player"=>"2", "average"=>"0.0", "difficulty"=>"1", "max_player"=>"10"},
      "authors"=>{"0"=>{"display_name"=>"Wolfgang - Kramer"}, "1"=>{"display_name"=>""}, "2"=>{"display_name"=>""}}
    }
    login_as(:quentin)
    post :create, form
    assert_response :redirect
    assert_not_nil(assigns(:game), "Cannot find @game")
    assert_equal(assigns(:game).authors.size, 1 )
  end
  
  def test_create_should_tag_game
    form = {
      "game"=>{"name"=>"6 qui prend", "publish_year"=>"", "url"=>"", "description"=>"boom", "editor"=>"Amigo", "min_player"=>"2", "average"=>"0.0", "difficulty"=>"1", "max_player"=>"10"},
      "tag"=>{"tag_list"=>"cartes,calcul,hasard"}
    }
    login_as(:quentin)
    post :create, form
    assert_response :redirect
    assert_not_nil(assigns(:game), "Cannot find @game")
    assert_equal(assigns(:game).tags.size, 3)
  end
  
  def test_update_should_update_authors
    form = {
      "game"=>{"name"=>"Amyitis", "publish_year"=>"2007", "url"=>"grrr", "description"=>"kaboom", 
                "editor"=>"Ystari",
                "min_player"=>"2",
                "average"=>"0.0",
                "difficulty"=>"4",
                "max_player"=>"4"},
       "tag"=>{"tag_list"=>"gestion"},
       "id"=> games(:battlelore).id,
       "game_photo"=>{"delete"=>"0",
       "uploaded_data"=>""},
       "authors"=>{"0"=>{"display_name"=>""},
       "1"=>{"display_name"=>""},
       "2"=>{"display_name"=>""}}
    }
    login_as(:quentin)
    post :update, form
    assert_response :redirect
    assert_redirected_to game_path(games(:battlelore))
    assert_not_nil(assigns(:game))
    assert_equal "Amyitis", assigns(:game).name
    assert_equal 0, assigns(:game).authors.size
  end
  
end
