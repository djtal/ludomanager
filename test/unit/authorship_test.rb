require File.dirname(__FILE__) + '/../test_helper'

class AuthorshipTest < Test::Unit::TestCase
  fixtures :all
  
  # Replace this with your real tests.
  def test_authors_should_be_unique_from_same_game
    assert clean_authorship.save
    assert !clean_authorship.save
  end
  
  def test_should_belong_to_game
    authorships(:one).game = games(:coloreto)
  end
  
  def test_should_belong_to_authors
    authorships(:one).author = authors(:kinizia)
  end
  
  def test_create_from_names
    data = {}
    data[:authorships] = { "1" => {:display_name => "test - a"}, "2" => {:dislpay_name => "test1 - b"}, 
                          "3" => {:display_name => "test2 - c"}}
    g = games(:coloreto)
    #assert_difference "g.authorships.count", 3 do
      g.authorships.create_from_names(data[:authorships])
    #end
    assert g.authors.map(&:display_name).include?("test - a")
  end
  
  def clean_authorship(overrides = {})
    opts = {
      :game_id => games(:battlelore).id,
      :author_id => authors(:kinizia).id
    }.merge(overrides)
    Authorship.new(opts)
  end
end
