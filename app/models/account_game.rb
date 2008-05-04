# == Schema Information
# Schema version: 29
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
#

class AccountGame < ActiveRecord::Base
  validates_presence_of :game_id, :account_id
  validates_uniqueness_of :game_id, :scope => :account_id
  belongs_to :game
  belongs_to :account
  before_create :setup_default
  

  def self.search params
    opts = {
      :include => {:game => :tags}
    }
    tag_list = Tag.parse(params[:search][:tags])
    if !params[:search][:player].blank?
      opts[:conditions] = ["games.min_player <= ? AND games.max_player >= ?", params[:search][:player], params[:search][:player]]
    end
    
    ag = self.find(:all, opts)
    if !tag_list.empty?
      ag = ag.select do |ag|
         found = ag.game.tags.inject(0){|acc, tag| acc + (tag_list.include?(tag.name) ? 1 : 0)}
         params[:search][:tags_mode] == "and" ? found == tag_list.size : found > 0
      end
    end
    ag.sort_by{|a| a.game.name}
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
    self.price ||= self.game.price
  end
  
end
