class AddUserApplicationSetup < ActiveRecord::Migration
  def self.up
    add_column :accounts, :game, :boolean, :default => true
    add_column :accounts, :party, :boolean, :default => true
    add_column :accounts, :member, :boolean, :default => true
  end

  def self.down
    remove_column :accounts, :member
    remove_column :accounts, :party
    remove_column :accounts, :game
  end
end
