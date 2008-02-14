require File.dirname(__FILE__) + '/../test_helper'
require 'authorships_controller'

# Re-raise errors caught by the controller.
class AuthorshipsController; def rescue_action(e) raise e end; end

class AuthorshipsControllerTest < Test::Unit::TestCase
  fixtures :authorships

  def setup
    @controller = AuthorshipsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:authorships)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_authorship
    old_count = Authorship.count
    post :create, :authorship => { }
    assert_equal old_count+1, Authorship.count
    
    assert_redirected_to authorship_path(assigns(:authorship))
  end

  def test_should_show_authorship
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_authorship
    put :update, :id => 1, :authorship => { }
    assert_redirected_to authorship_path(assigns(:authorship))
  end
  
  def test_should_destroy_authorship
    old_count = Authorship.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Authorship.count
    
    assert_redirected_to authorships_path
  end
end
