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

class InvalidDateRange < Exception; end

class Party < ActiveRecord::Base
  validates_presence_of :game_id, :account_id
  belongs_to :game
  belongs_to :account
  after_create :up_partie_cache, :update_played_date
  after_destroy :down_partie_cache
  
  named_scope :for_day, lambda{ |date| 
    { :conditions => ["parties.created_at BETWEEN ? AND ?", date.beginning_of_day, date.end_of_day], 
      :order => "parties.created_at ASC" }
  }
  
  def self.yearly_breakdown(opts = {})
    options = {
      :from => Time.zone.now.year, 
      :to => Time.zone.now.year,
      :scope => {}
    }.merge(opts)
    
    if options[:game]
      game = options.delete(:game)
      options[:scope] = {
        :conditions => {:game_id => game.id}
      }
    end
    return ActiveSupport::OrderedHash.new if  options[:from] == nil || options[:to] == nil
    raise InvalidDateRange if options[:from] > options[:to]
    yearly = (options[:from]..options[:to]).inject(ActiveSupport::OrderedHash.new) do |breakdown, year|
      breakdown[year] = (1..12).inject([]) do |acc, month|
        acc << self.count_by_month(:id, month, :year => year) do
          options[:scope]
        end
      end
      breakdown
    end
    yearly
  end
  
  def self.breakdown(key) 
    count(:include => :game, :group => "games.#{key.to_s}").inject({}) do |acc, data|
      acc[Game::Target[data[0].to_i][0]] = data[1]
      acc
    end
    
  end
  
  def self.player_breakdown(opts = {})
    return ActiveSupport::OrderedHash.new if self.count(:id, :conditions => { :game_id => opts[:game].id}) == 0
    self.count(:id, :conditions => {:game_id => opts[:game].id}, :group => :nb_player)
  end
  
  def self.play_range(opts = {})
    options = {}
    if opts[:game]
      options[:conditions] = {:game_id => opts[:game].id}
    end
    firstPlay = self.minimum(:created_at, options)
    from = firstPlay.year > 3.year.ago.year ? firstPlay.year : 3.year.ago.year
    {:from => from, :to => Time.zone.now.year}
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
  
  
  def find_account_game
    AccountGame.find(:first, :conditions => {:game_id => self.game_id, :account_id => self.account_id})
  end
  
end
