require 'test_helper'

class AccountGamesControllerTest < ActionController::TestCase
  
  context "a logged user" do
    setup{ login_as :quentin}
    
    context "go to index" do
      setup{ get :index}
      should_respond_with :success
      should_render_template :index
    end
    
    context "export his AccountGames" do
      setup{ get :index, :format => :csv}
      should_respond_with :success
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
  
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

