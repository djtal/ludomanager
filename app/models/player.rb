class Player < ActiveRecord::Base
  validates_presence_of :party_id, :member_id
  belongs_to :party
  belongs_to :member
  before_save :check_max_player
  
  def check_max_player
    self.party.game.max_player
  end
end
