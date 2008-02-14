class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :difficulty, :integer, :default => 1
    end
  end

  def self.down
    drop_table :games
  end
end
