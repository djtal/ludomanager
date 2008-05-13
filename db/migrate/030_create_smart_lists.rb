class CreateSmartLists < ActiveRecord::Migration
  def self.up
    create_table :smart_lists do |t|
      t.text :title
      t.text :query
      t.integer :account_id
      t.timestamps
    end
  end

  def self.down
    drop_table :smart_lists
  end
end
