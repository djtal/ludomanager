require 'test_helper'

class AuthorsControllerTest < ActionController::TestCase

  context "A logged user" do
    setup do
      login_as :quentin
    end
    
    context "GET index" do
      setup{ get :index}
      should_respond_with :success
    end
    
    context "GET new author form" do
      setup{ get :new}
      
      should_respond_with :success
    end
  end
  
  
  
  context "A non logged user" do
    
    context "GET index" do
      setup{ get :index}
      should_respond_with :success
    end
    
    context "GET new author form" do
      setup{ get :new}
      
      should_respond_with :redirect
      should_redirect_to "new_session_path"
    end
    
    context "GET edit author form" do
      setup{ get :edit, :id => authors(:kinizia).id}
      should_respond_with :redirect
      should_redirect_to "new_session_path"
    end
    
    context "DELETE an author" do
      setup{ delete :destroy ,:id => authors(:kinizia).id}
      
      should_respond_with :redirect
      should_redirect_to "new_session_path"
    end
    
    context "GET an author card" do
      setup{ get :show, :id => authors(:kinizia).id }
      should_respond_with :success
    end
  end
  

  def test_should_create_author
    old_count = Author.count
    post :create, :author => {:name => "test", :surname => "kk" }
    assert_equal old_count+1, Author.count
    
    assert_redirected_to author_path(assigns(:author))
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
