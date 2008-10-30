class AddEdtionToAccountGame < ActiveRecord::Migration
  def self.up
    add_column :account_games, :edition_id, :integer
    add_column :games, :extension, :boolean
  end

  def self.down
    remove_column :account_games, :edition_id
    remove_column :games, :extension
  end
end
