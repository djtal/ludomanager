class AddPartieCacheToAcGames < ActiveRecord::Migration
  def self.up
    add_column :account_games, :parties_count, :integer, :default => 0
  end

  def self.down
    remove_column :account_games, :parties_count
  end
end
