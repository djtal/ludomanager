require File.dirname(__FILE__) + '/../test_helper'
require 'dashboard_controller'

# Re-raise errors caught by the controller.
class DashboardController; def rescue_action(e) raise e end; end

context "Dashboard for non logged" do
  fixtures :accounts, :games, :parties
  
  def setup
    @controller = DashboardController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as(nil)
  end

  specify "index is not accessible" do
    get :index
    assert_response :redirect
    assert_redirected_to login_path
  end
  
end

context "Dashboard for logged user" do
  fixtures :accounts, :games, :parties
  
  def setup
    @controller = DashboardController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as(:quentin)
  end
  
  specify "index is accesible" do
    get :index
    assert_response :succes
    assert_template 'index'
  end
  
end

