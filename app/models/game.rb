# == Schema Information
# Schema version: 20090324224831
#
# Table name: games
#
#  id               :integer       not null, primary key
#  name             :string(255)   
#  description      :text          
#  difficulty       :integer(11)   default(2)
#  min_player       :integer(11)   default(1)
#  max_player       :integer(11)   
#  created_at       :datetime      
#  updated_at       :datetime      
#  url              :text          
#  average          :float         default(0.0)
#  target           :integer(11)   default(0)
#  time_category    :integer(11)   default(0)
#  box_file_name    :string(255)   
#  box_content_type :string(255)   
#  box_file_size    :integer       
#  box_updated_at   :datetime      
#

class Game < ActiveRecord::Base
  Target = [["Tous public", 0], ["Tres jeune enfant", 1], ["Jeunes enfant", 2], ["Casual", 3], ["Gamers", 4]]
  TimeCategory = [["< 30min", 0], ["Entre 30min/1h", 1],["Entre 1h et 1h30", 2], ["> 1h30", 3]]

  before_destroy :check_parties, :check_accounts
  after_save :merge_tags, :if => Proc.new{|game| !game.base_game_id.blank?}
  
  validates_presence_of :name, :difficulty, :min_player, :max_player
  validates_inclusion_of :difficulty, :in => 1..5
  validates_inclusion_of :target, :in => 0..4
  validates_inclusion_of :time_category, :in => 0..3
  validates_uniqueness_of :name, :case_sensitive => true
  validates_each :min_player, :max_player  do |record, attr, value|
    record.errors.add attr, 'ne peut pas etre  egal a 0' if value == 0
  end
  validate :min_max_player?

  has_many :extensions, :class_name => "Game", :foreign_key => "base_game_id", :dependent => :nullify
  belongs_to :base_game, :class_name => "Game", :foreign_key => "base_game_id"
  has_many :parties, :dependent => :destroy
  has_many :account_games
  has_many :authorships, :dependent => :destroy
  has_many :authors, :through => :authorships
  has_many :editions, :dependent => :destroy
  has_many :editors, :through => :editions
  
  has_attached_file :box,
                    :styles => { :thumb => ["35x35!", :png],
                                  :normal => ["70x70!", :png],
                                  :big => ["90x90!", :png]},
                    :default_url   => "/system/:attachment/:style/missing.png"
                    
  
  acts_as_taggable
  scope_procedure :start, searchlogic_lambda(:string) {|letter| name_begins_with_any(letter.downcase, letter.upcase).ascend_by_name}

  named_scope :extensions, :conditions => ["base_game_id <> ''"]
  named_scope :base_games, :conditions => ["base_game_id IS ? OR (base_game_id <> '' AND standalone = ? )",nil,  true]
  
    
  def self.search(query = "", page = 1)
    return [] if query.blank?
    games = find(:all, :conditions => ['LOWER(name) like ?', "%#{query.downcase}%"], :order => 'name')
    editions = Edition.find(:all, :conditions => ['LOWER(name) like ?', "%#{query.downcase}%"], :order => 'name').map(&:game)
    (games + editions).uniq.compact.sort_by(&:name).paginate(:per_page => 10, :page => page)
             
  end
  
  def self.first_letters
    find(:all, :select => :name).map{|a| a.name.first.downcase}.uniq
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
  
  
  def available_lang
    langs = []
    langs = editions.map(&:lang).compact.uniq if editions.any?
    langs
  end
  
  def tag_list
    tag_list = super()
    tag_list = self.base_game.tag_list if !self.base_game_id.blank? && tag_list.blank?
    tag_list
  end
  
  
  protected
  
  def merge_tags(extension = nil)
    if(!extension)
      extension = self
    end  
    new_tags = extension.tags + extension.base_game.tags
    new_tags.uniq.each do |t|
      t.on(extension) unless extension.tags.include?(t)
    end
  end
  
  def check_parties
  	!parties_exists?
 end
 
 def check_accounts
    !account_owned?
 end
end
