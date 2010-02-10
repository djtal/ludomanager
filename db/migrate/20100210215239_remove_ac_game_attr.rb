class RemoveAcGameAttr < ActiveRecord::Migration
  def self.up
    remove_column :games, :shield
    remove_column :games, :rules
    remove_column :games, :cheatsheet
  end

  def self.down
    add_column :games, :cheatsheet, :boolean
    add_column :games, :rules, :boolean
    add_column :games, :shield, :boolean
  end
end
