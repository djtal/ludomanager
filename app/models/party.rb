# encoding: UTF-8

class InvalidDateRange < Exception; end

class Party < ActiveRecord::Base
  validates :game_id, :account_id, presence: true

  belongs_to :game
  belongs_to :account

  after_create :up_partie_cache, :update_played_date
  after_destroy :down_partie_cache

  scope :for_day, lambda { |date|
    scope = where("parties.created_at BETWEEN ? AND ?", date.beginning_of_day, date.end_of_day)
    scope.order('parties.created_at ASC')
  }


  def self.yearly_breakdown(opts = {})
    options = {
      from: Time.zone.now.year,
      to: Time.zone.now.year,
      scope: {}
    }.merge(opts)

    if options[:game]
      game = options.delete(:game)
      options[:scope] = {
        conditions: { game_id: game.id }
      }
    end
    return ActiveSupport::OrderedHash.new if  options[:from] == nil || options[:to] == nil
    raise InvalidDateRange if options[:from] > options[:to]
    yearly = (options[:from]..options[:to]).inject({}) do |breakdown, year|
      breakdown[year] = (1..12).inject([]) do |acc, month|
        acc << self.by_month(month, year: year).count
      end
      breakdown
    end
    yearly
  end

  def self.breakdown(key)
    count(include: :game, group: "games.#{key.to_s}").inject({}) do |acc, data|
      acc[Game::Target[data[0].to_i][0]] = data[1]
      acc
    end

  end

  def self.player_breakdown(opts = {})
    where(game_id: opts[:game]).group(:nb_player).count(:id)
  end

  def self.play_range(opts = {})
    scope = self
    scope = self.where(game_id: opts[:game]) if opts[:game].present?

    from = if first_played = self.minimum(:created_at)
      first_played.year > 3.year.ago.year ? first_played.year : 3.year.ago.year
    else
      nil
    end
    { from: from, to: Time.zone.now.year }
  end

  def self.previous_play_date_from(date= Time.zone.now)
    where("created_at < ?", date.beginning_of_day).order(created_at: :desc).first
    p.present ? p.created_at  : nil
  end

  def self.next_play_date_from(date= Time.zone.now)
    where("created_at > ?", date.beginning_of_day).order(created_at: :desc).first
    p.present ? p.created_at  : nil
  end

  def self.replace_game(old_game, new_game)
    if new_game && !new_game.new_record?
      where(game_id: game.id).update_all(game_id: old_game.id)
    end
  end


  def self.by_game(game_first_letter = "")
    scope = self.includes(:game).group(:game)
    scope = scope.where("lower(games.name) LIKE ?", "#{game_first_letter}") if game_first_letter.present?
    scope.order('count_id desc').count(:id)
  end


  def self.last_play(count)
    order(created_at: :desc).limit(count)
  end

  def self.most_played(year = Time.zone.now.year, opts = {})
    options = {
      count: 5
    }.reverse_merge(opts)
    scope = self.includes(:game).group(:game)
    if year.to_i > 0
      start_date = (year.to_i - Time.now.year).year.from_now.beginning_of_year
      scope = scope.where"parties.created_at BETWEEN ? AND ?", start_date, start_date.end_of_year
    end
    scope = scope.limit(options[:count])
    scope.order('count_id desc').count(:id)
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
    AccountGame.where(game_id: self.game_id, account_id: self.account_id).first
  end

end
