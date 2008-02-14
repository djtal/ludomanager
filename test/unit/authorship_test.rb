require File.dirname(__FILE__) + '/../test_helper'

class AuthorshipTest < Test::Unit::TestCase
  fixtures :authorships, :authors, :games

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
  
  def clean_authorship(overrides = {})
    opts = {
      :game_id => games(:battlelore).id,
      :author_id => authors(:kinizia).id
    }.merge(overrides)
    Authorship.new(opts)
  end
end
