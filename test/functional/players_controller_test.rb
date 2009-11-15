require 'test_helper'

class PlayersControllerTest < ActionController::TestCase
  context "A logged user" do
    setup{ login_as :quentin}
    
    context "getting new player form" do
      setup do
        p = Factory.create(:party, :account_id => accounts(:quentin).id)
        get :new, :party_id => p.id
      end
      should_respond_with :success

    end
    
    context "editing players for a partie" do
      setup do
        p = Factory.create(:party, :account_id => accounts(:quentin).id)
        m1 = Factory.create(:member, :account_id => accounts(:quentin).id)
        pl = Factory.create(:player, :party_id => p.id, :member_id => m1.id)
        get :edit, :party_id => p.id, :id => pl.id
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
