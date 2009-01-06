require File.dirname(__FILE__) + '/../test_helper'
require 'parties_controller'

# Re-raise errors caught by the controller.
class PartiesController; def rescue_action(e) raise e end; end

class PartiesControllerTest < Test::Unit::TestCase
  fixtures :all
  
  def setup
    @controller = PartiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_create_should_handle_multiple_parties_at_once
    login_as :quentin
    data = {}
    data["parties"] = {
      "1"=>{"game_id"=>games(:coloreto).id, "created_at"=>"2008-04-04"}, 
      "2"=>{"game_id"=>games(:coloreto).id, "created_at"=>"2008-04-04"}
    }
    assert_difference "Party.count", 2 do
      post "create", data
      assert_response :success
      assert_template "create"
      assert_equal("2008-04-04".to_time, assigns(:date), "Cannot find @date")
      assert_equal(2, assigns(:parties).size, "Cannot find @parties")
    end
  end
  
  def test_create_should_handle_one_party
    login_as :quentin
    data = {}
    data["parties"] = {"1"=>{"game_id"=>games(:coloreto).id, "created_at"=>"2008-04-04"}}
    assert_difference "Party.count", 1 do
      post "create", data
      assert_response :success
      assert_template "create"
      assert_equal("2008-04-04".to_time, assigns(:date), "Cannot find @date")
      assert_equal(1, assigns(:parties).size, "Cannot find @parties")
    end
  end
  
end