class CreateParties < ActiveRecord::Migration
  def self.up
    create_table :parties do |t|
      t.column :game_id, :integer
      t.column :created_at, :datetime
    end
    
    add_column :games, :parties_count, :integer
  end

  def self.down
    drop_table :parties
  end
end
