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
      setup{ get :index, :format => :csv}
      should_respond_with :success
    end
    
    context "go to new account game form" do
      setup{ get :new}
      should_respond_with :success
      should_render_template :new
      should_assign_to :account_game
      
      should "default new account game date to current date" do
        Time.zone = 'Paris'
        assert_equal Time.zone.now.beginning_of_day, assigns(:account_game).transdate
      end
    end
  end
  
  context "a non logged user" do
    [:index, :show, :edit, :new].each do |action|
      context "go to #{action}" do
        setup{ get action}
        should_redirect_to "new_session_path"
      end
    end
  end
end

