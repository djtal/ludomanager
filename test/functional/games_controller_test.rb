require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  
  context "getting index page" do
    context "with no parameters set" do
      setup { get :index }

      should_respond_with :success
      should_render_template :index
      should_not_set_the_flash 
      should_assign_to :games
    end
    
    context "seeting first letter" do
      setup do
        5.times{|t| Factory.create(:game, :name => "a#{t}")}
        get :index, :start => "A"
      end

      should_respond_with :success
      should_render_template :index
      should_not_set_the_flash 
      should_assign_to :games
      should_assign_to :first_letters, :class => Array
      should "filter only games starting with first_letters" do
        assigns(:games).each do |g|
          assert g.name.downcase.start_with?("a")
        end
      end
    end
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
      end
  end
  
  context "on GET to :index in JSON" do
    
    context "for all game including extension" do
      setup do
        get :index, :format => "json"
      end

      should_respond_with :success
      should_respond_with_content_type :json
    end
    
    context "for all game that can be extension for another game" do
      setup do
        get :index, :format => "json", :type => "base_game"
      end
      
      should_respond_with :success
      should_respond_with_content_type :json
    end
    
  end
    
  
  
  
  context "a logged User" do
    setup{ login_as :quentin}
    
    context "CREATE a new game" do
      context "with no title" do
        setup do
          post :create, :game => Factory.attributes_for(:game, :name => "")
        end
        should_respond_with :success
        should_render_template :new
      end
      
      context "with no tags and no authors" do
        setup do
          post :create, :game => Factory.attributes_for(:game)
        end
        should_respond_with :redirect
      end
      
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
