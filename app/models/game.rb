# == Schema Information
#
# Table name: games
#
#  id           :integer       not null, primary key
#  name         :string(255)   
#  description  :text          
#  difficulty   :integer       default(1)
#  min_player   :integer       default(1)
#  max_player   :integer       
#  price        :float         
#  time_average :string(255)   
#  created_at   :datetime      
#  updated_at   :datetime      
#  publish_year :string(255)   
#  editor       :string(255)   
#  url          :text          
#  average      :float         default(0.0)
#



class Game < ActiveRecord::Base
  Target = [["Tous public", 0], ["Tres jeune enfant", 1], ["Jeunes enfant", 2], ["Casual", 3], ["Gamers", 4]]

  before_destroy :check_parties, :check_accounts
  validates_presence_of :name, :difficulty, :min_player, :max_player
  validates_inclusion_of :difficulty, :in => 1..5
  validates_inclusion_of :target, :in => 1..5
  validates_uniqueness_of :name, :message => "Desolé ce jeu existe deja"
  
  validates_each :min_player, :max_player  do |record, attr, value|
    record.errors.add attr, 'ne peut pas etre  egal a 0' if value == 0
  end
  validate :min_max_player?
  has_one :image, :class_name => "GamePhoto", :foreign_key => "game_id", :dependent => :destroy
  has_many :parties, :dependent => :destroy
  has_many :account_games
  has_many :authorships, :dependent => :destroy
  has_many :authors, :through => :authorships
  
  acts_as_taggable
  
  def self.search(query, page)
    paginate :per_page => 5, :page => page,
             :conditions => ['LOWER(name) like ?', "%#{query}%"], :order => 'name'
  end
  
  def min_max_player?
    if min_player && max_player
      self.errors.add :max_player, "le nombre maxi de joueur ne peut etre inferieur au nombre mini" if min_player > max_player
    end
  end

  def target_str
    self.class::Target[target][0]
  end
  
  
  def parties_exists?
    parties.size > 0
  end
  
  def account_owned?
    account_games.size > 0
  end
  
  
  protected
  
  def check_parties
  	!parties_exists?
 end
 
 def check_accounts
    !account_owned?
 end
end
