# encoding: UTF-8

class AccountGame < ActiveRecord::Base
  validates :game_id, :account_id, presence: true
  validates :game_id, uniqueness: { scope: :account_id }

  belongs_to :game
  belongs_to :edition
  belongs_to :account

  before_create :setup_default

  scope :recent, -> { where("account_games.transdate > ?", 3.month.ago)}
  scope :no_played, -> { where("parties_count = 0") }
  scope :game_extensions, -> { joins(:game).merge(Game.extensions) }
  scope :base_games, -> { joins(:game).merge(Game.base_games) }


  def self.replace_game(old_game, new_game)
    if new_game && !new_game.new_record?
      update_all("game_id = #{new_game.id}", game_id: old_game.id)
    end
  end

  def self.breakdown(key)
    joins(:game).group("games.#{key.to_s}").count.inject({}) do |acc, data|
      acc[Game::Target[data[0].to_i][0]] = data[1]
      acc
    end
  end


  def recenty_acquired?
    return self.transdate > 3.month.ago
  end

  def played?
    parties_count > 0
  end

  def parties_played_count
    Party.where(game_id: game_id, account_id: account_id).count
  end

  def to_json
    Jbuilder.encode do |json|
      json.extract!(self, :id, :created_at)
      json.game do |g|
        json.extract! game, :id, :name, :min_player, :max_player
        json.extension game.extension?
      end
    end
  end

  protected

  def setup_default
    self.transdate ||= Time.now.to_date
    self.parties_count = self.parties_played_count
  end

end
