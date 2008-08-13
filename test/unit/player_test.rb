require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  fixtures :all
  
  def test_should_block_if_game_max_player_reached
    party = accounts(:quentin).parties.build(:game => games(:battlelore))
    assert party.save
    assert party.players.build(:member => members(:luke)).save
    assert party.players.build(:member => members(:anakin)).save
    assert !party.allow_more_players?
    assert !party.players.build(:member => members(:jabba)).save
  end
  
  def test_should_not_allow_the_same_player_twice_per_party
    party = accounts(:quentin).parties.build(:game => games(:battlelore))
    assert party.save
    assert party.players.build(:member => members(:luke)).save
    assert !party.players.build(:member => members(:luke)).save
  end
  
end
