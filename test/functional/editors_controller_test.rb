require 'test_helper'

class EditorsControllerTest < ActionController::TestCase
  context "a logged user" do
    setup do
      login_as :quentin  
    end 
    
    context "GET the editors index page" do
      setup{ get :index}
      
      should_respond_with :success
      should_assign_to :editors
    end
    
    context "GET an editor page" do
      setup{ get :show, :id => editors(:ystari).id}
      should_respond_with :success
      should_assign_to :editor, :equals => "editors(:ystari)"
    end
    
    should "GET edit form" do
      get :edit, :id => editors(:ystari).id
      assert_response :success
      assert_template :edit
    end
    
    context "GET new editor form" do
      setup{ get :new}
      should_respond_with :success
      should_render_template :new
    end
    
    context "POST a new editor" do
      should "create a new editor with valid data" do
        assert_difference "Editor.count" do
          post :create, :editor => Factory.attributes_for(:editor)
          assert_response :redirect
          assert_template :show
        end
      end
      
      should "set logo if file is uploaded" do
        post :create, :editor => Factory.attributes_for(:editor, :name => "toto", :logo => fixture_file_upload("test_image.jpg", "image/jpg"))
        assert_response :redirect
        assert_template :show
        editor = assigns(:editor)
        assert editor.logo.file?
      end
      
      should "redirect to form if invalid data" do
        assert_no_difference "Editor.count" do
          post :create, :editor => Factory.attributes_for(:editor, :name => "")
          assert_response :success
          assert_template :new
        end
      end
      
      
    end
    
    context "UPDATE an editor" do
      setup do
        put :update, :id => editors(:ystari).id, :editor => Factory.attributes_for(:editor, :name => "toto")
      end
      should_respond_with :redirect
      should_redirect_to "editor_path(editors(:ystari))"
      should_assign_to :editor
      should_change "Editor.find(editors(:ystari).id).name", :to => "toto"
    end
    
    context "DELETE an editor" do
      setup{ delete  :destroy, :id => editors(:ystari).id}
      should_change "Editor.count", :by => -1
      should_respond_with :redirect
      should_redirect_to "editors_path"
    end
  end
  
  context "a non logged user" do
    context "GET the editors index page" do
      setup{ get :index}
      should_respond_with :success
      should_assign_to :editors
    end
    
    should "GET editor page filtered if supply start letter for editor" do
      get :index, :start => "Y"
      assert_response :success
      assert_not_nil(assigns(:editors))
      assert assigns(:editors).first.name.first, "Y"
    end
    
    
    context "GET an editor page" do
      setup{ get :show, :id => editors(:ystari).id}
      should_respond_with :success
      should_assign_to :editor, :equals => "editors(:ystari)"
    end
    
    context "GET new editor form" do
      setup{ get :new}
      should_respond_with :redirect
      should_redirect_to "new_session_path"
    end
    
    context "DELETE an editor" do
      setup{ delete  :destroy, :id => editors(:ystari).id}
      should_not_change "Editor.count"
      should_respond_with :redirect
      should_redirect_to "new_session_path"
    end
    
    should "be redirected when trying to edit an editor" do
      get :edit, :id => editors(:ystari).id
      assert_response :redirect
      assert_redirected_to new_session_path
    end
  end

end
