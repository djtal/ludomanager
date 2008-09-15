# == Schema Information
<<<<<<< master:app/models/game.rb
# Schema version: 20080731203551
=======
# Schema version: 20080817160324
>>>>>>> local:app/models/game.rb
#
# Table name: games
#
#  id            :integer       not null, primary key
#  name          :string(255)   
#  description   :text          
#  difficulty    :integer(11)   default(2)
#  min_player    :integer(11)   default(1)
#  max_player    :integer(11)   
#  created_at    :datetime      
#  updated_at    :datetime      
#  publish_year  :string(255)   
#  editor        :string(255)   
#  url           :text          
#  average       :float         default(0.0)
<<<<<<< master:app/models/game.rb
#  min_age       :integer(11)   
=======
#  min_age       :integer       
>>>>>>> local:app/models/game.rb
#  vo_name       :text          
#  target        :integer       default(0)
#  time_category :integer       default(0)
#  published_at  :date          
#

<<<<<<< master:app/models/game.rb

=======
>>>>>>> local:app/models/game.rb
class Game < ActiveRecord::Base
  Target = [["Tous public", 0], ["Tres jeune enfant", 1], ["Jeunes enfant", 2], ["Casual", 3], ["Gamers", 4]]
  TimeCategory = [["< 30min", 0], ["Entre 30min/1h", 1],["Entre 1h et 1h30", 2], ["> 1h30", 3]]

  before_destroy :check_parties, :check_accounts
  validates_presence_of :name, :difficulty, :min_player, :max_player
  validates_inclusion_of :difficulty, :in => 1..5
  validates_inclusion_of :target, :in => 0..4
  validates_inclusion_of :time_category, :in => 0..3
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
  named_scope :without_text, :conditions => {:description => nil}
  named_scope :for_two, :conditions => {:min_player => 2, :max_player => 2}
  
  
  #
  def self.search(query, page = 1)
    return [] if query.blank?
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
  
  def time_str
    self.class::TimeCategory[time_category][0]
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
