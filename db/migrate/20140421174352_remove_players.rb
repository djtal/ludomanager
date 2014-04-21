class RemovePlayers < ActiveRecord::Migration
  def self.up
    drop_table :players
  end

  def self.down
    create_table "players", :force => true do |t|
      t.integer  "party_id",   :limit => 11
      t.integer  "member_id",  :limit => 11
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
