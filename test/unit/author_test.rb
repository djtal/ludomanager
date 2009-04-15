require 'test_helper'

class AuthorTest < ActiveSupport::TestCase

  context "a Author" do
    #should_validate_presence_of :name, :surname
    should_have_many :authorships, :dependent => :destroy
    should_have_many :games, :through => :authorships
    
  end

  context "create an author from string" do
    
    should "work with blank string" do
      name, surname = Author.parse_str("")
       assert_equal "", surname
       assert_equal "", name
    end
    
    should "extract name and surname without - char" do
      name, surname = Author.parse_str "Reiner - Kinizia"
      assert_equal "Reiner", surname
      assert_equal "Kinizia", name
    end
    
    should "extract name and surname with compound name" do
      name, surname = Author.parse_str "Franz Benno - Delonge"
      assert_equal "Franz Benno", surname
      assert_equal "Delonge", name
    end
  end
  
  def test_find_or_create_from_str
    assert !Author.find_or_create_from_str("")
    assert !Author.find_or_create_from_str
    assert_equal authors(:kinizia), Author.find_or_create_from_str("Reiner - Kinizia")
    assert_equal authors(:kinizia), Author.find_or_create_from_str("Kinizia - Reiner")
    
    assert_difference "Author.count" do
      Author.find_or_create_from_str("Seyrfath - Andreas")
    end
    assert_no_difference "Author.count "do
      Author.find_or_create_from_str("")
    end
    
    assert_no_difference" Author.count" do
      Author.find_or_create_from_str("Vialla")
    end
  end
  
  def test_display_name_write_accessor
    a =Author.new
    a.display_name = "Bruno - Cathala"
    assert_equal  "Cathala", a.name
    assert_equal "Bruno", a.surname
  end
end
