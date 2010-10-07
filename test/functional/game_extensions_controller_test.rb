require 'test_helper'

class GameExtensionsControllerTest < ActionController::TestCase
  
  context "adding extensions to game" do
    setup do
      @base = Factory.create(:game, :name => "Race for the galaxy")
      @ext = Factory.create(:game, :name => "Rebel vs Imperium")
    end
    
    context "on GET to :new" do
      setup { get :new, :game_id => @base.id }

      should_respond_with :success
      should_assign_to(:base_game, :class => Game) {@base}
      should_assign_to(:extension, :class => Game)
      
      should "setup exntesion with base_game_id" do
        assert_equal @base.id, assigns(:extension).base_game_id
      end
    end
    
    context "on POST to :create" do
      setup { post :create, :game => { :id => @ext.id, :base_game_id => @base.id } }
      
      should_respond_with :redirect
      should_redirect_to("base game path") {game_path(@base)}
      
      should "update the base_game_id of the extension with game.id" do
        assert_equal @base.id, @ext.reload.base_game_id
      end
    end
    
    context "on POST to :create with no id for extension" do
      setup { post :create, :game => { :id => "", :base_game_id => @base.id } }
      should_render_template :new
      should_assign_to(:base_game, :class => Game){@base}
      should_assign_to(:extension, :class => Game)
      
      should "setup extension with base_game_id" do
        assert_equal @base.id, assigns(:extension).base_game_id
      end
    end
    
    
  end
end
