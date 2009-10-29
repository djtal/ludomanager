require 'test_helper'

class PlayersControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  context "A logged user" do
    setup{ login_as :quentin}
    
    context "creating new player for a party" do
      setup do
        p = Factory.create(:party, :account_id => accounts(:quentin).id)
        get :new, :party_id => p.id
      end
      should_respond_with :success

    end
    
  end

  context "registering player for parties" do
    should "add player to party" do

    end
    
    should_eventually "register player for current parties and go to next party" do
      flunk
    end
    
    should_eventually "register player and go to day parties list" do
      flunk
    end
  end
end
