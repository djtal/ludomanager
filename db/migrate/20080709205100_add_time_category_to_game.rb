class AddTimeCategoryToGame < ActiveRecord::Migration
  def self.up
    add_column :games, :time_category, :integer, :default => 0
  end

  def self.down
    remove_column :games, :time_category
  end
end
