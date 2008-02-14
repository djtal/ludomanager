# == Schema Information
# Schema version: 29
#
# Table name: account_games
#
#  id         :integer       not null, primary key
#  game_id    :integer       
#  account_id :integer       
#  created_at :datetime      
#  origin     :text          
#  price      :float         
#  transdate  :datetime      
#  shield     :boolean       
#

class AccountGame < ActiveRecord::Base
  validates_presence_of :game_id, :account_id
  validates_uniqueness_of :game_id, :scope => :account_id
  belongs_to :game
  belongs_to :account
  before_save :set_date

  def image
    game.image
  end
  
  def parties_count
    account.parties.find(:all, :conditions => {:game_id => game_id}).size
  end
  
  def recenty_acquired?
    return self.transdate > 3.month.ago
  end
  
  protected
  
  def set_date
    self.transdate = Time.now.to_s(:db) if !self.transdate
  end
  
end
