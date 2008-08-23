# == Schema Information
# Schema version: 20080710200139
#
# Table name: account_games
#
#  id            :integer       not null, primary key
#  game_id       :integer       
#  account_id    :integer       
#  created_at    :datetime      
#  origin        :text          
#  price         :float         
#  transdate     :datetime      
#  shield        :boolean       
#  parties_count :integer       default(0)
#  rules         :boolean       
#  cheatsheet    :boolean       
#


class AccountGame < ActiveRecord::Base
  validates_presence_of :game_id, :account_id
  validates_uniqueness_of :game_id, :scope => :account_id
  belongs_to :game
  belongs_to :account
  before_create :setup_default
  #need to play with named_scope
  named_scope :recent, lambda { { :conditions => ['created_at > ?', 2.month.ago] } }
  
  cattr_reader :per_page
  @@per_page = 50
  
  def self.replace_game(old_game, new_game)
    if new_game && !new_game.new_record?
      update_all("game_id = #{new_game.id}", :game_id => old_game.id) 
    end
  end
  
  
  def self.search(query = {})
    opts = {
      :include => {:game => :tags},
      :order => "games.name ASC",
      :page => query.delete(:page)
    }
    if query[:search]
      @tag_list = Tag.parse(query[:search][:tags]) if query[:search][:tags]
      criterion = {}
      if !query[:search][:player].blank?
        criterion["games.min_player <= ?"] = query[:search][:player]
        criterion["games.max_player >= ?"] = query[:search][:player]
      end
      if !query[:search][:difficulty].blank?
        criterion["games.difficulty <= ?"] = query[:search][:difficulty]
      end
      if !query[:search][:parties].blank?
         criterion["account_games.parties_count <= ?"] = query[:search][:parties]
      end
      opts[:conditions]  = [criterion.keys.join(" AND "), criterion.values].flatten if !criterion.empty?
      
      opts[:limit] = query[:search][:limit] if !query[:search][:limit].blank?
    end
    @ag = self.paginate(:all, opts)
    #filter for tags
    if @tag_list && !@tag_list.empty?
      @ag = @ag.select do |ag|
         found = ag.game.tags.inject(0){|acc, tag| acc + (@tag_list.include?(tag.name) ? 1 : 0)}
         query[:search][:tags_mode] == "and" ? found == @tag_list.size : found > 0
      end
    end
    @ag
  end
  
  def self.last_buy(count, opts = {})
    options = {
      :limit => count,
      :order => "account_games.created_at DESC"
    }.merge(opts)
    find(:all, options)
  end
  
  def image
    game.image
  end
  
  
  def recenty_acquired?
    return self.transdate > 3.month.ago
  end
  
  protected
  
  def setup_default
    self.transdate ||= Time.now.to_date
  end
  
end
