require 'test_helper'

class PartiesControllerTest < ActionController::TestCase
  
  context "a logged user" do
    setup do
      login_as :quentin
      Time.zone = 'Paris'
    end
    
    context "GET parties index" do
      setup do
        get :index
      end

      should_respond_with :success
      should_render_template :index
      should_assign_to(:date){Time.now}
    end
    
    context "GET index for a date" do
      setup{ get :index}
    end
    
    context "GET most played game" do
      context "with a given year" do
        setup{ xhr :get, :most_played, :year => 2008}
        should_respond_with :success
        should_respond_with_content_type :js
        should_render_template :most_played
      end
      
      context "without a given year" do
        setup{ xhr :get, :most_played}
        should_respond_with :success
        should_respond_with_content_type :js
        should_render_template :most_played
      end

    end

    
    context "viewing parties per day" do
      setup{ Time.zone = 'Paris'}
      should "show parties for current day" do
        get :show
        assert_equal Time.zone.now.to_date, assigns(:date)
      end
      
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