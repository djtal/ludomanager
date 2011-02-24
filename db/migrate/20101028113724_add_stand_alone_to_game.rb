class AddStandAloneToGame < ActiveRecord::Migration
  def self.up
    add_column :games, :standalone, :boolean
    remove_column :games, :is_extension
  end

  def self.down
    remove_column :games, :standalone
    
  end
end