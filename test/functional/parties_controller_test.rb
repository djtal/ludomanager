require 'test_helper'

class PartiesControllerTest < ActionController::TestCase
  
  context "a logged user" do
    setup do
      login_as :quentin
      Time.zone = 'Paris'
    end
    
    context "GET parties index" do
      setup do
        get :index
      end

      should_respond_with :success
      should_render_template :index
      should_assign_to(:date)
    end
    
    context "GET index for a date" do
      setup{ get :index}
    end
    
    context "viwewing all played parties" do
      setup do
        get :all
      end
      should_respond_with :success
      should_render_template :all
      should_assign_to(:first_letters)
    end
    
    context "GET most played game" do
      context "with a given year" do
        setup{ xhr :get, :most_played, :year => 2008}
        should_respond_with :success
        should_respond_with_content_type :js
        should_render_template :most_played
      end
      
      context "without a given year" do
        setup{ xhr :get, :most_played}
        should_respond_with :success
        should_respond_with_content_type :js
        should_render_template :most_played
      end

    end

    
    context "viewing parties per day" do
      setup{ Time.zone = 'Paris'}
      should "show parties for current day if no date is supplied" do
        get :show
        assert_equal Time.zone.now.to_date, assigns(:date).to_date
      end
      
      should "show parties for given day if date suplied" do
        
      end
      
      should "know next day played" do
        
      end
      
      should "know previous play day" do
        
      end
    end
  end
  

  context "logged user playing parties" do
      setup do
        Time.zone = 'Paris'
        @played_game1 = Factory(:game, :name => "6 Nimt")
        @played_game2 = Factory(:game, :name => "11 Nimt")
        @user = Factory(:account, :login => "djtal")
        @request.session[:account_id] = @user.id
        @play_date = "2008-04-04"
      end

      context "registering multiple parties of simple game at once" do
        setup do
          xhr :post, :create, :parties => {
            "1" => {:game_id => @played_game1.id, :created_at => @play_date},
            "2" => {:game_id => @played_game2.id, :created_at => @play_date},
            "3" => {:game_id => @played_game2.id, :created_at => @play_date},
          }
        end
        should_respond_with :success
        should_render_template :create
        should_respond_with_content_type :js
        should_assign_to(:parties, :class => Array)

        should "create parties at the given date" do
          assert_equal 3, assigns(:parties).size
        end
      end
      
      context "registering parties with a number of player" do
        setup do
           xhr :post, :create, :parties => {
              "1" => {:game_id => @played_game1.id, :created_at => @play_date, :nb_player => 4},
              "2" => {:game_id => @played_game2.id, :created_at => @play_date, :nb_player => 3},
              "3" => {:game_id => @played_game2.id, :created_at => @play_date, :nb_player => 6},
            }
        end
        should_respond_with :success
        should_render_template :create
        should_respond_with_content_type :js
        should_assign_to(:parties, :class => Array)

        should "create parties at the given date" do
          assert_equal 3, assigns(:parties).size
        end
      end
      
    end
  
end