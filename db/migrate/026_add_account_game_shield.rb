class AddAccountGameShield < ActiveRecord::Migration
  def self.up
    add_column :account_games, :shield, :boolean
  end

  def self.down
    remove_column :account_games, :shield
  end
end
