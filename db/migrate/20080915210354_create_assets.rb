class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string  "content_type"
      t.string  "filename"
      t.integer "size",         :limit => 11
      t.integer "width",        :limit => 11
      t.integer "height",       :limit => 11
      t.references :attachable, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
end
