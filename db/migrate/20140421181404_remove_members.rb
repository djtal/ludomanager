class RemoveMembers < ActiveRecord::Migration
  def self.up
    drop_table :members
  end

  def self.down
    create_table "members", :force => true do |t|
      t.text     "name"
      t.text     "nickname"
      t.integer  "account_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "email"
    end
  end
end
