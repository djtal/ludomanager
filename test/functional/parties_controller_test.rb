require File.dirname(__FILE__) + '/../test_helper'
require 'parties_controller'

# Re-raise errors caught by the controller.
class PartiesController; def rescue_action(e) raise e end; end

context "registerd user can" do
  fixtures :accounts, :parties, :games
  
  def setup
    @controller = PartiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as(:quentin)
  end

  specify "can create multiple party at once" do
    
  end
  
  
end

context "Non Registered user cannot" do
  fixtures :parties, :games, :accounts
  
  def setup
    @controller = PartiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as(nil)
  end
  
  specify "create some parties" do
    assert_no_difference Party, :count do
      post :create, :game_id => games(:battlelore).id
    end
    assert_response :redirect
    assert_redirected_to login_path
  end
  
end
