require 'test_helper'

class PartiesControllerTest < ActionController::TestCase
  
  context "logged user" do
    setup {login_as :quentin}
    
    context " GET parties overview" do
      setup do
        get :index
      end

      should_respond_with :success
      should_render_template :index
      should_assign_to :parties
      should_assign_to :yours
      should_assign_to :other
      should_assign_to :last_played
    end

    context "GET parties for current month" do
      setup do
        get :resume
      end

      should_respond_with :success

    end
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