require 'test_helper'

class GameExtensionsControllerTest < ActionController::TestCase
  
  context "on GET to :index" do
    setup do
      @base = Factory(:game)
      5.times do
        Factory.create(:extension, :base_game => @base)
      end
      get :index, :format => "json"
      @games = Game.extensions.find(:all)
    end
    
    should_respond_with :success
    should_respond_with_content_type :json
  end
  
  context "adding extensions to game" do
    setup do
      @base = Factory.create(:game, :name => "Race for the galaxy")
      @ext = Factory.create(:game, :name => "Rebel vs Imperium")
      @ext2 = Factory.create(:game, :name => "Gathering Storm")
      @ext3 = Factory.create(:game, :name => "The Brink of War")
    end
    
    context "on GET to :new" do
      setup { get :new, :game_id => @base.id }

      should_respond_with :success
      should_assign_to(:base_game, :class => Game) {@base}
      should_assign_to(:extensions, :class => Array)
      
    end
    
    context "on POST to :create with one extension" do
      setup { post :create, :game_id => @base.id, :games => {"1" => { :id => @ext.id, :base_game_id => @base.id } }}
      
      should_respond_with :redirect
      should_redirect_to("base game path") {game_path(@base)}
      
      should "update the base_game_id of the extension with game.id" do
        assert_equal @base.id, @ext.reload.base_game_id
      end
    end
    
    context "on POST to :create with no id for extension" do
      setup { post :create, :game_id => @base.id, :games => {"1" => { :id => "", :base_game_id => @base.id } }}
      should_render_template :new
      should_assign_to(:base_game, :class => Game){@base}
      should_assign_to(:extensions, :class => Array)
    end
    
    context "on POST to :create with multiple extensions" do
      setup do
        post :create, :game_id => @base.id, :games => {
          "1" => { :id => @ext.id, :base_game_id => @base.id },
          "2" => { :id => @ext2.id, :base_game_id => @base.id },
          "3" => { :id => @ext3.id, :base_game_id => @base.id }
        }
      end
      should_respond_with :redirect
      should_redirect_to("base game path") {game_path(@base)}

      should "update the base_game_id of the extensions with game.id" do
        assert_equal @base.id, @ext.reload.base_game_id
        assert_equal @base.id, @ext2.reload.base_game_id
        assert_equal @base.id, @ext3.reload.base_game_id
        assert_equal 3, @base.reload.extensions.count
      end
    end
    
  end
end
