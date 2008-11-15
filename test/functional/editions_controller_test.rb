require 'test_helper'

class EditionsControllerTest < ActionController::TestCase
  fixtures :all
  
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:editions)
  end



  def test_should_destroy_edition
    assert_difference('Edition.count', -1) do
      delete :destroy, :id => editions(:battlelore_fr).id
    end

    assert_redirected_to editions_path
  end
end
