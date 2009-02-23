require 'test_helper'

class AuthorsControllerTest < ActionController::TestCase

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:authors)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_author
    old_count = Author.count
    post :create, :author => {:name => "test", :surname => "kk" }
    assert_equal old_count+1, Author.count
    
    assert_redirected_to author_path(assigns(:author))
  end

  def test_should_show_author
    get :show, :id => authors(:kinizia).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => authors(:kinizia).id
    assert_response :success
  end
  
  def test_should_update_author
    put :update, :id => authors(:kinizia).id, :author => { }
    assert_redirected_to author_path(assigns(:author))
  end
  
  def test_should_destroy_author
    old_count = Author.count
    delete :destroy, :id => authors(:kinizia).id
    assert_equal old_count-1, Author.count
    
    assert_redirected_to authors_path
  end
end
