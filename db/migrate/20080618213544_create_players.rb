class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.belongs_to :party
      t.belongs_to :member
      t.timestamps
    end
  end

  def self.down
    drop_table :players
  end
end
