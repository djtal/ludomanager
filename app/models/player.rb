# == Schema Information
# Schema version: 20080817160324
#
# Table name: players
#
#  id         :integer       not null, primary key
#  party_id   :integer       
#  member_id  :integer       
#  created_at :datetime      
#  updated_at :datetime      
#

class Player < ActiveRecord::Base
  validates_presence_of :party_id, :member_id
  belongs_to :party
  belongs_to :member
  validates_uniqueness_of :member_id, :scope => :party_id
  before_save :party_allow_more_player?

  def display_name
    @name ||= member.display_name if member
  end
  
  def party_allow_more_player?
    party.allow_more_players?
  end
  
end
