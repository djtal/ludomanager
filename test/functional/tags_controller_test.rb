require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  
  context "get SHOW tag" do
    context "with a tag which not exist" do
      setup do
        get :show, :id => "test"
      end
      should_respond_with :success
      should_assign_to(:tag)
      should "not save the tag" do
        assert assigns(:tag).new_record?
      end
    end
    
    context "with a tags with games" do
      setup do
        @tag = Factory.create(:tag)
        (1..5).each do
          g = Factory.create(:game_seq)
          g.tag_with(@tag.name)
          g.save
        end
        get :show, :id => @tag.name
      end
      should_respond_with :success
      should_render_template :show
      should_assign_to (:games)
      should_assign_to(:tag) {@tag}
      
      should "contains games tagged with" do
        assert_equal 5, assigns(:games).size
      end
    end
  end
  
  
  context "GET tags index" do
    context "without filter" do
      setup {get :index}
      should_respond_with :success
      should_assign_to(:cloud)
      should_assign_to(:first_letters) 
    end
    
    context "filtered by tag first letter" do
      setup do
        %W(a b c d).each_with_index do |letter, index|
          (index + 1).times do |time|
            Factory.create(:tag, :name => letter * time)
          end
        end
        get :index, :start => "c"
      end
      should_assign_to(:first_letters)
      should_assign_to(:cloud)
      should "contain only tags starting with given start letter" do
        assert_equal 3, assigns(:cloud).size
        assigns.each do |tag|
          assert_equal "a", tag.name.first.downcase
        end
      end
    end
  end

end
