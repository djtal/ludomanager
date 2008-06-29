# == Schema Information
# Schema version: 30
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
  after_create :up_partie_cache
  after_destroy :down_partie_cache
  
  
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
      :order => "parties.created_at DESC",
      :include => [:game => :image]
    }.merge(opts)
    find(:all, options)
  end
  
  def self.most_played(count, opts = {})
    options = {
      :select => "game_id, COUNT(id) AS total",
      :group => "game_id",
      :order => "total DESC",
      :limit => count,
    }.merge(opts)
    parties = find(:all, options)
    games = Game.find(:all, :conditions => {:id => parties.map(&:game_id)}, :include => :image).to_a
    parties.inject({}) do |h, p|
      h.merge({games.find{|g| g.id == p.game_id} => p.total.to_i})
    end
  end
  
  def up_partie_cache
    ac = AccountGame.find(:first, :conditions => {:game_id => self.game_id, :account_id => self.account_id})
    if ac
      ac.parties_count += 1
      ac.save
    end
  end
  
  def down_partie_cache
    ac = AccountGame.find(:first, :conditions => {:game_id => self.game_id, :account_id => self.account_id})
    if ac
      ac.parties_count -= 1
      ac.save
    end
  end
  
end
