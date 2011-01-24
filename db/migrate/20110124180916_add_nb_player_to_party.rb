class AddNbPlayerToParty < ActiveRecord::Migration
  def self.up
    add_column :parties, :nb_player, :integer
  end

  def self.down
    remove_column :parties, :nb_player
  end
end