class CreateEditions < ActiveRecord::Migration
  def self.up
    create_table :editions do |t|
      t.integer :game_id
      t.integer :editor_id
      t.text :lang
      t.text :name
      t.date :published_at
      t.timestamps
    end
  end

  def self.down
    drop_table :editions
  end
end
