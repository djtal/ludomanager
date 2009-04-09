class CreateHomepages < ActiveRecord::Migration
  def self.up
    create_table :homepages do |t|
      t.belongs_to :account
      t.boolean :public
      t.text :title
      t.timestamps
    end
  end

  def self.down
    drop_table :homepages
  end
end
