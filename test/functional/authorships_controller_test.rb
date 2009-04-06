require 'test_helper'

class AuthorshipsControllerTest < ActionController::TestCase

  context "a logged user" do
    setup{ login_as :quentin}
    should "GET new authorship form" do
      get :new, :game_id => games(:coloreto).id
      assert_response :success
    end
    
    should "GET a new form fragment when requestion a new authors for a game via js" do
      get :new_partial_form, :index => 1, :format => :js
      assert_response :success
    end
  end
end
