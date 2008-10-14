require 'test_helper'

class EditionsControllerTest < ActionController::TestCase
  fixtures :all
  
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:editions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_edition
    assert_difference('Edition.count') do
      post :create, :edition => { }
    end

    assert_redirected_to edition_path(assigns(:edition))
  end

  def test_should_show_edition
    get :show, :id => editions(:battlelore_fr).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => editions(:battlelore_fr).id
    assert_response :success
  end

  def test_should_update_edition
    put :update, :id => editions(:battlelore_fr).id, :edition => { }
    assert_redirected_to edition_path(assigns(:edition))
  end

  def test_should_destroy_edition
    assert_difference('Edition.count', -1) do
      delete :destroy, :id => editions(:battlelore_fr).id
    end

    assert_redirected_to editions_path
  end
end
