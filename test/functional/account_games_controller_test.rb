require 'test_helper'

class AccountGamesControllerTest < ActionController::TestCase
  
  context "a logged user" do
    setup{ login_as :quentin}
    
    context "go to index" do
      setup{ get :index}
      should_respond_with :success
      should_render_template :index
    end
    
    context "go to search" do
      setup{ get :search}
      should_respond_with :success
      should_render_template :all
    end
    
    context "export his AccountGames" do
      setup{ get "index.csv"}
      should_respond_with :success
    end
    
    context "go to new account game form" do
      setup{ get :new}
      should_respond_with :success
      should_render_template :new
      should_assign_to :account_games
    end
    
    context "creating new game(s)" do
      setup do
        @g1 = Factory.create(:game, :name => "Arkham Horror")
        @g2 = Factory.create(:game, :name => "Pandemic")
        @g3 = Factory.create(:game, :name => "Castle Panic")
        @ac1 = Factory.attributes_for(:account_game, :game_id => @g1.id)
        @ac2 = Factory.attributes_for(:account_game, :game_id => @g2.id)
        @ac3 = Factory.attributes_for(:account_game, :game_id => @g3.id)
      end
      
      
      should "create one game" do
        assert_difference("accounts(:quentin).account_games.count", 1) do 
          post :create, {:account_game => {"1" => @ac1}}
        end
      end
      
      should "create multiple game in one times" do
        assert_difference("accounts(:quentin).account_games.count", 2) do 
          post :create, {:account_game => {"1" => @ac1, "2" => @ac2}}
        end
        assert_redirected_to :account_games
      end
      
      should "create only filled account games" do
        assert_difference("accounts(:quentin).account_games.count", 1) do 
          post :create, {:account_game => {"1" => @ac1, "2" => {:game_id => ""}, "3" => {:game_id => ""}}}
        end
        
        assert_redirected_to account_games_path
      end
    end
  end
  
  context "a non logged user" do
    [:index, :show, :edit, :new].each do |action|
      context "go to #{action}" do
        setup{ get action}
        should_redirect_to("login_path"){new_session_path}
      end
    end
  end
end

