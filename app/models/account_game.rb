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
  scope_procedure :start, searchlogic_lambda(:string) {|letter| game_name_begins_with_any(letter.downcase, letter.upcase).ascend_by_game_name}
  
  cattr_reader :per_page
  @@per_page = 50
  
  def self.replace_game(old_game, new_game)
    if new_game && !new_game.new_record?
      update_all("game_id = #{new_game.id}", :game_id => old_game.id) 
    end
  end
  
  def self.breakdown(key) 
    count(:include => :game, :group => "games.#{key.to_s}").inject({}) do |acc, data|
      acc[Game::Target[data[0].to_i][0]] = data[1]
      acc
    end
    
  end
  
  # work like a find but order group games and extensions
  #
  def self.find_sort(opts = {})
    account_games = self.paginate(opts)
    base_games, extensions = account_games.partition{|ac_game| ac_game.game.base_game_id.blank?}
    order_account_games = base_games.sort_by{|ac_game| ac_game.game.name}.inject([]) do |acc, ac_game|
      exts = extensions.select{|ext| ext.game.base_game_id == ac_game.game_id}
      acc << ac_game
      acc << exts unless (exts.empty?)
      acc
    end.flatten
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
