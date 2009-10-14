# == Schema Information
# Schema version: 20090324224831
#
# Table name: account_games
#
#  id            :integer       not null, primary key
#  game_id       :integer(11)   
#  account_id    :integer(11)   
#  created_at    :datetime      
#  origin        :text          
#  price         :float         
#  transdate     :datetime      
#  shield        :boolean       
#  parties_count :integer(11)   default(0)
#  rules         :boolean       
#  cheatsheet    :boolean       
#  edition_id    :integer       
#



class AccountGame < ActiveRecord::Base
  validates_presence_of :game_id, :account_id
  validates_uniqueness_of :game_id, :scope => :account_id
  belongs_to :game
  belongs_to :account
  before_create :setup_default
  #need to play with named_scope
  named_scope :recent, lambda { { :conditions => ['created_at > ?', 3.month.ago] } }
  named_scope :no_played, :conditions => {:parties_count => 0}
  
  cattr_reader :per_page
  @@per_page = 50
  
  def self.replace_game(old_game, new_game)
    if new_game && !new_game.new_record?
      update_all("game_id = #{new_game.id}", :game_id => old_game.id) 
    end
  end
  
  
  def self.prepare_search(params = {})
    search = self.search
    
    if params[:player].to_i > 0
      search.game_min_player_lte(params[:player])
      search.game_max_player_gte(params[:player])
    end
    
    if !params[:tags].blank?
      tags = params[:tags].split(/\s|,\s*|;\s*/)
      if params[:tags_mode] == "or"
        search.game_tags_name_like_any(tags)
      else
        search.game_tags_name_like_all(tags)
      end
    end
    search
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
  
  def played?
    parties_count > 0
  end
  
  def parties_played_count
    Party.count(:conditions => {:game_id => game_id, :account_id => account_id})
  end
  
  protected
  
  def setup_default
    self.transdate ||= Time.now.to_date
    self.parties_count = self.parties_played_count
  end
  
end
