class AddAttrsToAcGames < ActiveRecord::Migration
  def self.up
    change_table :account_games do |t|
      t.boolean :rules
      t.boolean :cheatsheet
    end
  end

  def self.down
    change_table :account_games do |t|
      t.remove :rules
      t.remove :cheatsheet
    end
  end
end
