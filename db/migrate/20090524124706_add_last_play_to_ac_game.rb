class AddLastPlayToAcGame < ActiveRecord::Migration
  def self.up
    add_column :account_games, :last_play, :date
  end

  def self.down
    remove_column :account_games, :last_play
  end
end
