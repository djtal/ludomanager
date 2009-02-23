require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# context "Dashboard for non logged" do
#   fixtures :all
#   
#   def setup
#     @controller = DashboardsController.new
#     @request    = ActionController::TestRequest.new
#     @response   = ActionController::TestResponse.new
#     login_as(nil)
#   end
# 
#   specify "index is not accessible" do
#     get :show
#     assert_response :redirect
#     assert_redirected_to login_path
#   end
#   
# end
# 
# context "Dashboard for logged user" do
#   fixtures :all
#   
#   def setup
#     @controller = DashboardsController.new
#     @request    = ActionController::TestRequest.new
#     @response   = ActionController::TestResponse.new
#     login_as(:quentin)
#   end
#   
#   specify "index is accesible" do
#     get :show
#     assert_response :success
#   end
#   
# end

