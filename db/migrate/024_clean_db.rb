class CleanDb < ActiveRecord::Migration
  def self.up
    remove_column :games, :comment_age
    remove_column :games, :parties_count
    drop_table :events
    drop_table :comments
    drop_table :articles
  end

  def self.down
    add_column :games, :comment_age, :integer
    add_column :games, :parties_count, :integer

  end
end
