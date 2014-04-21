class RemoveGamePhotos < ActiveRecord::Migration
  def self.up
    drop_table :game_photos
  end

  def self.down
    create_table "game_photos", :force => true do |t|
      t.string  "content_type"
      t.string  "filename"
      t.integer "size"
      t.integer "parent_id"
      t.string  "thumbnail"
      t.integer "width"
      t.integer "height"
      t.integer "game_id"
    end
  end
end
