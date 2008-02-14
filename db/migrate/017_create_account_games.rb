class CreateAccountGames < ActiveRecord::Migration
  def self.up
    create_table :account_games do |t|
      t.column :game_id, :integer
      t.column :account_id, :integer
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :account_games
  end
end
