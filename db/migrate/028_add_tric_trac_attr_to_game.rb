class AddTricTracAttrToGame < ActiveRecord::Migration
  def self.up
    add_column :games, :url, :text
    add_column :games, :average, :float, :default => 0
  end

  def self.down
    remove_column :games, :url
    remove_column :games, :average
  end
end
