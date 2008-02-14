# == Schema Information
# Schema version: 29
#
# Table name: parties
#
#  id         :integer       not null, primary key
#  game_id    :integer       
#  created_at :datetime      
#  account_id :integer       
#

class Party < ActiveRecord::Base
  validates_presence_of :game_id, :account_id
  belongs_to :game
  belongs_to :account
end
