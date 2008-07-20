require File.dirname(__FILE__) + '/../test_helper'

class AuthorTest < Test::Unit::TestCase
  fixtures :all

  
  def test_parse_str_should_extract_name_and_surname
    str = "Reiner - Kinizia"
    name, surname = Author.parse_str str
    assert_equal "Reiner", surname
    assert_equal "Kinizia", name
    
    name, surname = Author.parse_str("")
    assert_equal "", surname
    assert_equal "", name
    name, surname = Author.parse_str
    name, surname = Author.parse_str("")
    assert_equal "", surname
    assert_equal "", name
    
    str = "Reiner Kinizia"
    name, surname = Author.parse_str str
    assert_equal "Reiner", surname
    assert_equal "Kinizia", name
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
  
  def test_should_clear_games_if_deleted
    g = games(:coloreto)
    assert g.authors.include?(authors(:kinizia))
    assert authors(:kinizia).destroy
    assert !g.authors.include?(authors(:kinizia))
  end
  
  def should_delete_autorships_when_destroy
    a = authors(:kinizia)
    assert_equal 3, Authorship.find_by_author_id(authors(:kinizia).id)
    assert a.destroy
    assert_equal 0, Authorship.find_by_author_id(authors(:kinizia).id)
  end
end
