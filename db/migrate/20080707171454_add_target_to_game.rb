class AddTargetToGame < ActiveRecord::Migration
  def self.up
    add_column :games, :target, :integer, :default => 0
  end

  def self.down
    remove_column :games, :target
  end
end
