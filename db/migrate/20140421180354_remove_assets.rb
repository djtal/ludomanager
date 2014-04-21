class RemoveAssets < ActiveRecord::Migration
  def self.up
    drop_table :assets
  end

  def self.down
    create_table "assets", :force => true do |t|
      t.string   "content_type"
      t.string   "filename"
      t.integer  "size",            :limit => 8
      t.integer  "width",           :limit => 8
      t.integer  "height",          :limit => 8
      t.integer  "attachable_id"
      t.string   "attachable_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
