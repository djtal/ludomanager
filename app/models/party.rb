# == Schema Information
# Schema version: 20090324224831
#
# Table name: parties
#
#  id         :integer       not null, primary key
#  game_id    :integer(11)   
#  created_at :datetime      
#  account_id :integer(11)   
#

class Party < ActiveRecord::Base
  validates_presence_of :game_id, :account_id
  belongs_to :game
  belongs_to :account
  has_many :players, :dependent => :destroy
  after_create :up_partie_cache, :update_played_date
  after_destroy :down_partie_cache
  
  named_scope :for_day, lambda{ |date| 
    { :conditions => ["parties.created_at BETWEEN ? AND ?", date.beginning_of_day, date.end_of_day], 
      :order => "parties.created_at ASC" }
  }
  
  def self.yearly_breakdown(fromYear = Time.now.year, toYear = Time.now.year)
    return ActiveSupport::OrderedHash.new if  fromYear == nil || toYear == nil
    raise Exception if fromYear > toYear
    yearly = (fromYear..toYear).inject(ActiveSupport::OrderedHash.new) do |breakdown, year|
      breakdown[year] = (1..12).inject([]) do |acc, month|
        acc << self.count_by_month(:id, month, :year => year)
      end
      breakdown
    end
    yearly
  end
  
  def self.previous_play_date_from(date= Time.zone.now)
    p = find(:first, :conditions => ["created_at < ?", date.beginning_of_day], :order => "created_at DESC")
    return p.created_at if p
    nil
  end
  
  def self.next_play_date_from(date= Time.zone.now)
    p = find(:first, :conditions => ["created_at > ?", date.end_of_day], :order => "created_at ASC")
    return p.created_at if p
    nil
  end
  
  def self.replace_game(old_game, new_game)
    if new_game && !new_game.new_record?
      update_all("game_id = #{new_game.id}", :game_id => old_game.id) 
    end
  end
  
  
  def self.by_game(game_first_letter = "")
    opts = {
      :include => :game,
      :group => :game,
      :order => "count_id DESC"
    }
    opts[:conditions] = ["lower(games.name) LIKE ?", "#{game_first_letter.downcase}%"] if game_first_letter
    count(:id, opts)
  end
  
  
  def self.last_play(count, opts = {})
    options = {
      :limit => count,
      :order => "parties.created_at DESC"
    }.merge(opts)
    find(:all, options)
  end
  
  def self.most_played(count, year = nil)
    opts = {
      :group => :game,
      :order => "count_id DESC",
      :limit => count
    }
    if year != nil && year.to_i > 0  
      start_date = Time.now.in((year.to_i - Time.now.year).year).beginning_of_year
      end_date = start_date.end_of_year
      opts[:conditions] = ["parties.created_at BETWEEN ? AND ?", start_date, end_date]
    end
    calculate(:count, :id, opts)
  end
  
  def members
    players.map(&:member).compact
  end
  
  def up_partie_cache
    ac = self.find_account_game
    if ac
      ac.parties_count += 1
      ac.save
    end
  end
  
  def down_partie_cache
    ac = self.find_account_game
    if ac
      ac.parties_count -= 1
      ac.save
    end
  end
  
  def update_played_date
    ac = self.find_account_game
    if ac
      ac.last_play = self.created_at
      ac.save
    end
  end
  
  def allow_more_players?
    players.count < game.max_player
  end
  
  
  def find_account_game
    AccountGame.find(:first, :conditions => {:game_id => self.game_id, :account_id => self.account_id})
  end
  
end
