require 'test_helper'

class EditionsControllerTest < ActionController::TestCase
  
  
  context "a logged user" do
    setup{ login_as :quentin}
    
    should "GET new edition form for a game" do
      get :new , :game_id => games(:coloreto).id
      assert_response :success
    end
    
    should "GET edit an edition" do
      game = Factory.create(:game)
      edition = Factory.create(:edition, :game => game)
      get :edit, :game_id => game.id, :edition_id => edition.id
      assert_response :success
    end
    
    should "DELETE an edition" do
        assert_difference('Edition.count', -1) do
          delete :destroy, :id => editions(:battlelore_fr).id
        end
        assert_redirected_to editions_path
    end
  end
  
  
  context "a  non logged user" do
    
    should "not GET new edition form for a game" do
      get :new , :game_id => games(:coloreto).id
      assert_response :redirect
      assert_redirected_to new_session_path
    end
    
    should "not DELETE a edition for a game" do
      assert_no_difference('Edition.count') do
        delete :destroy, :id => editions(:battlelore_fr).id
      end
      assert_response :redirect
      assert_redirected_to new_session_path
    end
  end
  
end
