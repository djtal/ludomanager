require File.dirname(__FILE__) + '/../test_helper'

class TestTagParser < Test::Unit::TestCase
  fixtures :games
  
  def test_should_rais_error_on_invalid_macro
      source = %q(
      base sur le concept de <grrrrr:4> BattleLore l'enrichie de nombreux sytemes tout en gardant
      ca simplicite.
      Une belle reussite en soit.)
      
      assert_raise(RuntimeError) {
        TeamScore::Filter.filter(source)
      }
  end
  
  def test_should_replace_game_tag_by_a_link_to_the_specified_game
    src = "<game:#{games(:battlelore).id}>"
    expected = "\"#{games(:battlelore).name}\":http://www.teamscore.org/games/#{games(:battlelore).id}"
    assert_equal expected, TeamScore::Filter.filter(src)
  end

end
