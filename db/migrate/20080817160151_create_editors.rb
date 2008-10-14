class CreateEditors < ActiveRecord::Migration
  def self.up
    create_table :editors do |t|
      t.text :name, :homepage
      t.timestamps
    end
  end

  def self.down
    drop_table :editors
  end
end
