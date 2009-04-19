require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  
  context "a non logged user GET general games page" do
    setup { get :index }
      
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash 
    should_assign_to :games
  end
  
    
  context "a non logged user GET a specific game page" do
      setup{ get :show, :id => games(:coloreto)}
      should_respond_with :success
      should_render_template :show
      should_assign_to :game
      should_assign_to :editions
      
      should "not DELETE a game" do
        assert_no_difference "Game.count"do
          delete :destroy, :id => 1
        end    
        assert_redirected_to new_session_path
      end
  end
  
  
  context "a logged user add a new game" do
    setup{ login_as :quentin}
    context "game does not match required data" do
      setup do
        post :create, Factory.attributes_for(:game, :title => "")
      end
      should_respond_with :success
      should_render_template :new
    end
  end
  
  
  def test_logged_user_can_delete_with_no_parties
    login_as(:quentin)
    assert_difference "Game.count", -1 do
      delete :destroy, :id => games(:no_played).id
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
  
  def test_create_should_register_authors
    form = {
      "game"=>{"name"=>"6 qui prend", "url"=>"", "description"=>"balh", "min_player"=>"2", "average"=>"0.0", "difficulty"=>"1", "max_player"=>"10"},
      "authorship"=>{"0"=>{"display_name"=>"Wolfgang - Kramer"}}
    }
    login_as(:quentin)
    post :create, form
    assert_response :redirect
    assert_not_nil(assigns(:game), "Cannot find @game")
    assert_equal(assigns(:game).authors.size, 1 )
  end
  
  def test_create_with_blank_authors_name_should_skip_blank
    form = {
      "game"=>{"name"=>"6 qui prend", "url"=>"", "description"=>"balh",  "min_player"=>"2", "average"=>"0.0", "difficulty"=>"1", "max_player"=>"10"},
      "authorship"=>{"0"=>{"display_name"=>"Wolfgang - Kramer"}, "1" => {"display_name"=>" "}}
    }
    assert_nothing_raised do
      login_as(:quentin)
      post :create, form
    end
  end
  
  def test_create_with_no_authors_part_should_create_game
    form = {
      "game"=>{"name"=>"6 qui prend", "url"=>"", "description"=>"balh", "min_player"=>"2", "average"=>"0.0", "difficulty"=>"1", "max_player"=>"10"}
    }
    assert_nothing_raised do
      login_as(:quentin)
      post :create, form
    end
  end
  
  def test_create_should_tag_game
    form = {
      "game"=>{"name"=>"6 qui prend", "url"=>"", "description"=>"boom",  "min_player"=>"2", "average"=>"0.0", "difficulty"=>"1", "max_player"=>"10"},
      "tag"=>{"tag_list"=>"cartes,calcul,hasard"},
      "authorship"=>{"0"=>{"display_name"=>"zz-top"}}
    }
    login_as(:quentin)
    post :create, form
    assert_response :redirect
    assert_not_nil(assigns(:game), "Cannot find @game")
    assert_equal(assigns(:game).tags.size, 3)
  end
  
  def test_update_should_update_authors
    form = {
      "game"=>{"name"=>"Amyitis", "url"=>"grrr", "description"=>"kaboom", 
                "min_player"=>"2",
                "average"=>"0.0",
                "difficulty"=>"4",
                "max_player"=>"4"},
       "tag"=>{"tag_list"=>"gestion"},
       "id"=> games(:battlelore).id,
       "game_photo"=>{"delete"=>"0",
       "uploaded_data"=>""},
       "authorship"=>{"0"=>{"display_name"=>"zz-top"}}
    }
    login_as(:quentin)
    post :update, form
    assert_response :redirect
    assert_redirected_to game_path(games(:battlelore))
    assert_not_nil(assigns(:game))
    assert_equal "Amyitis", assigns(:game).name
    assert_equal 1, assigns(:game).authors.size
  end
  
  def test_merge_games
    login_as(:quentin)
    post :merge, {"replace"=>{"destination"=>"", "destination_id"=> games(:coloreto).id}, "id"=> games(:battlelore).id}
    assert_redirected_to game_path(games(:coloreto).id)
    assert_equal 0, Party.find_all_by_game_id(games(:battlelore).id).size
    assert_equal 0, AccountGame.find_all_by_game_id(games(:battlelore).id).size
  end
  
  def test_merge_without_destination_game
    login_as(:quentin)
    post :merge, {"replace"=>{"destination"=>"", "destination_id"=> ""}, "id"=> games(:battlelore).id}
    assert_redirected_to game_path(games(:battlelore).id)
  end
  
end
