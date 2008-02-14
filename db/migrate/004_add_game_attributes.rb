class AddGameAttributes < ActiveRecord::Migration
  def self.up
    add_column :games, :min_player, :integer, :default => 1
    add_column :games, :max_player, :integer
  end

  def self.down
    remove_column :games, :min_player
    remove_column :games, :max_player
  end
end
