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
  after_create :up_partie_cache
  after_destroy :down_partie_cache
  
  
  
  def self.yearly_breakdown(fromYear = Time.now.year, toYear = Time.now.year)
    raise Exception if fromYear > toYear
    yearly = (fromYear..toYear).inject(ActiveSupport::OrderedHash.new) do |breakdown, year|
      breakdown[year] = (1..12).inject([]) do |acc, month|
        start = DateTime.civil(year, month)
        acc << self.count(:all, :conditions => ["created_at BETWEEN ? AND ?",start, start.end_of_month ])
      end
      breakdown
    end
    yearly
  end
  
  
  def self.replace_game(old_game, new_game)
    if new_game && !new_game.new_record?
      update_all("game_id = #{new_game.id}", :game_id => old_game.id) 
    end
  end
  
  def self.find_by_month(date = Time.now, opts = {})
    options = {
      :conditions => ["parties.created_at BETWEEN ? AND ?", date.beginning_of_month, date.end_of_month]
    }.merge(opts)
    self.find(:all, options)
  end
  
  def self.group_by_game
    find(:all, :include => :game).group_by(&:game).sort_by{ |game, parties| parties.size}.reverse
  end
  
  def self.by_game
    count(:id, :group => :game, :order => "count_id DESC")
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
  
  def self.parties_for(year = nil)
    opts = {
      #:group => :game,
      #:order => "count_id DESC",
      :limit => count
    }
    
    if year != nil && year.to_i > 0
      
      start_date = Time.now.in((year.to_i - Time.now.year).year).beginning_of_year
      end_date = start_date.end_of_year
      logger.debug { "start #{start_date} end #{end_date}" }
      opts[:conditions] = ["parties.created_at BETWEEN ? AND ?", start_date, end_date]
    end
    find(:all, opts)
  end
  
  def members
    players.map(&:member).compact
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
  
  def allow_more_players?
    players.count < game.max_player
  end
  
end
