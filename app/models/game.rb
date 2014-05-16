# encoding: UTF-8

class Game < ActiveRecord::Base
  Target = [["Tous public", 0], ["Tres jeune enfant", 1], ["Jeunes enfant", 2], ["Casual", 3], ["Gamers", 4]]
  TimeCategory = [["< 30min", 0], ["Entre 30min/1h", 1],["Entre 1h et 1h30", 2], ["> 1h30", 3]]

  before_destroy :check_parties, :check_accounts
  after_save :merge_tags, if: proc { |game| !game.base_game_id.blank? }

  validates :name, :difficulty, :min_player, :max_player, presence: true
  validates :difficulty, inclusion: { in: 1..5 }
  validates :target, inclusion: { in: 0..4 }
  validates :time_category, inclusion: { in: 0..3 }
  validates :name, uniqueness: { case_sensitive: true }
  validates :min_player, :max_player, numericality: { greater_than: 0}
  validate :min_max_player?

  has_many :extensions, class_name: 'Game', foreign_key: 'base_game_id', dependent: :nullify
  belongs_to :base_game, class_name: 'Game', foreign_key: 'base_game_id'
  has_many :parties, dependent: :destroy
  has_many :account_games
  has_many :authorships, dependent: :destroy
  has_many :authors, through: :authorships
  has_many :editions, dependent: :destroy
  has_many :editors, through: :editions

  has_attached_file :box,
                    styles: { thumb: ['35x35!', :png],
                              normal: ['70x70!', :png],
                              big: ['90x90!', :png]},
                    default_url: '/system/:attachment/:style/missing.png'
  validates_attachment :box, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }


  acts_as_taggable

  scope :extensions, -> { where.not(base_game_id: nil) }
  scope :base_games, -> { where("base_game_id IS ? OR (base_game_id <> '' AND standalone = ? )", nil, true) }
  scope :for_text, lambda { |q| where('LOWER(name) like ?', "%#{q.downcase}%")}
  scope :latest, lambda { |l| order(:created_at).limit(l) }

  def self.search(query = "", page = 1)
    return [] if query.blank?
    games = for_text(query).to_a + Edition.for_text(q).includes(:game)
    (games + editions).uniq.compact.sort_by(&:name).paginate(per_page: 10, page: page)
  end

  def self.first_letters
    all.pluck(:name).map { |n| name.first.downcase }.uniq
  end


  def extension?
    !self.base_game_id.blank?
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
    editions.pluck('DISTINCT lang')
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
