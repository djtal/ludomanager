class AddAttrsToGame < ActiveRecord::Migration
  def self.up
    change_table :games do |t|
      t.integer :min_age
      t.text :vo_name
    end
  end

  def self.down
    change_table :games do |t|
      t.remove :min_age
      t.remove :vo_name
    end
  end
end
