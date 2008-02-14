class AddGameTimestamp < ActiveRecord::Migration
  def self.up
    add_column :games, :created_at, :datetime
    add_column :games, :updated_at, :datetime
  end

  def self.down
    remove_column :games, :created_at
    remove_column :games, :updated_at
  end
end
