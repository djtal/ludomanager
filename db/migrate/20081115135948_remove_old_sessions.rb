class RemoveOldSessions < ActiveRecord::Migration
  def self.up
    drop_table "sessions"
    drop_table "game_extensions"
    remove_columns :games, :publish_year, :min_age, :editor, :vo_name, :published_at, :extension
  end

  def self.down
    create_table "sessions", :force => true do |t|
      t.string   "session_id"
      t.text     "data"
      t.datetime "updated_at"
    end
  end
end
