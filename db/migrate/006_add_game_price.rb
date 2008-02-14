class AddGamePrice < ActiveRecord::Migration
  def self.up
    add_column :games, :price, :float
    add_column :games, :time_average, :string
  end

  def self.down
    remove_column :games, :price
    remove_column :games, :time_average
  end
end
