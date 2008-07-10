class UpdateGameAttr < ActiveRecord::Migration
  def self.up
    change_table :games do |t|
      t.change :difficulty, :integer, :default => 2
      t.date :published_at
      t.remove :price
      t.remove :time_average
    end
  end

  def self.down
    change_table :games do |t|
      t.change :difficulty, :integer, :default => 1
      t.remove :published_at
      t.float :price
      t.text :time_average
    end
  end
end
