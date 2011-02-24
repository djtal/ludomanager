class AddExtensionToGame < ActiveRecord::Migration
  def self.up
    add_column :games, :base_game_id, :integer
    add_column :games, :is_extension, :boolean
  end

  def self.down
    remove_column :games, :is_extension
    remove_column :games, :base_game_id
  end
end
