require 'test_helper'

class EditionTest < ActiveSupport::TestCase
  fixtures :all
  
  def test_name_should_be_same_as_game_if_not_prvided
    e = games(:battlelore).editions.build(:editor => editors(:ystari))
    assert e.save
    assert_equal e.game, games(:battlelore)
    assert_equal games(:battlelore).name, e.name 
  end
end
