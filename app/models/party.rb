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
  
  def self.find_by_month(date = Time.now, opts = {})
    options = {
      :conditions => ["parties.created_at BETWEEN ? AND ?", date.beginning_of_month, date.end_of_month]
    }.merge(opts)
    self.find(:all, options)
  end
  
  def self.group_by_game
    find(:all, :include => :game).group_by(&:game).sort_by{ |game, parties| parties.size}.reverse
  end
  
  def self.last_play(count, opts = {})
    options = {
      :limit => count,
      :order => "parties.created_at DESC"
    }.merge(opts)
    find(:all, options)
  end
  
end
