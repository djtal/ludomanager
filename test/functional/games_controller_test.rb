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
  
  def test_create_register_authors
    form = {
      "game"=>{"name"=>"6 qui prend", "time_average"=>"30min", "publish_year"=>"", "url"=>"", "description"=>"Soyez malin et choissiez la valuer de votre carte mais garre a celles choisi par vos adeversaire.\r\nAyez le moins de tete de betail possible a la fin de chaque manche pour remportez la victoire.", "editor"=>"Amigo", "min_player"=>"2", "average"=>"0.0", "difficulty"=>"1", "max_player"=>"10"},
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
      "game"=>{"name"=>"6 qui prend", "time_average"=>"30min", "publish_year"=>"", "url"=>"", "description"=>"Soyez malin et choissiez la valuer de votre carte mais garre a celles choisi par vos adeversaire.\r\nAyez le moins de tete de betail possible a la fin de chaque manche pour remportez la victoire.", "editor"=>"Amigo", "min_player"=>"2", "average"=>"0.0", "difficulty"=>"1", "max_player"=>"10"},
      "tag"=>{"tag_list"=>"cartes,calcul,hasard"}
    }
    login_as(:quentin)
    post :create, form
    assert_response :redirect
    assert_not_nil(assigns(:game), "Cannot find @game")
    assert_equal(assigns(:game).tags.size, 3)
  end
  
end
