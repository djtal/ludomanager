class RemoveSmartList < ActiveRecord::Migration
  def self.up
    drop_table :smart_lists
  end

  def self.down
    create_table "smart_lists", :force => true do |t|
      t.text     "title"
      t.text     "query"
      t.integer  "account_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
