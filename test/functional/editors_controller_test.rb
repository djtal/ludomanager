require 'test_helper'

class EditorsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:editors)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_editor
    assert_difference('Editor.count') do
      post :create, :editor => { }
    end

    assert_redirected_to editor_path(assigns(:editor))
  end

  def test_should_show_editor
    get :show, :id => editors(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => editors(:one).id
    assert_response :success
  end

  def test_should_update_editor
    put :update, :id => editors(:one).id, :editor => { }
    assert_redirected_to editor_path(assigns(:editor))
  end

  def test_should_destroy_editor
    assert_difference('Editor.count', -1) do
      delete :destroy, :id => editors(:one).id
    end

    assert_redirected_to editors_path
  end
end
