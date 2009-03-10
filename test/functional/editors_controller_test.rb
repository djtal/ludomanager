require 'test_helper'

class EditorsControllerTest < ActionController::TestCase
  context "a logged user" do
    setup{ login_as :quentin}
    
    context "GET the editors index page" do
      setup{ get :index}
      
      should_respond_with :success
      should_assign_to :editors
    end
    
  end
  
  context "a non logged user" do
    context "GET the editors index page" do
      setup{ get :index}
      should_respond_with :success
      should_assign_to :editors
    end
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
    get :show, :id => editors(:ystari).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => editors(:ystari).id
    assert_response :success
  end

  def test_should_update_editor
    put :update, :id => editors(:ystari).id, :editor => { }
    assert_redirected_to editor_path(assigns(:editor))
  end

  def test_should_destroy_editor
    assert_difference('Editor.count', -1) do
      delete :destroy, :id => editors(:ystari).id
    end

    assert_redirected_to editors_path
  end
end
