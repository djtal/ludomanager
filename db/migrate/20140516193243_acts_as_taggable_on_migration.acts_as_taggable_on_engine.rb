# This migration comes from acts_as_taggable_on_engine (originally 1)
class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up

    add_column :tags, :taggings_count, :integer, default: 0

    change_table :taggings do |t|
      t.references :tagger, polymorphic: true

      # Limit is created to prevent MySQL error on index
      # length for MyISAM table type: http://bit.ly/vgW2Ql
      t.string :context, limit: 128

      t.datetime :created_at
    end

    remove_index :taggings, name: 'index_taggings_on_tag_id_and_taggable_id_and_taggable_type'

    add_index :taggings,
              [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type],
              unique: true, name: 'taggings_idx'

    remove_index :tags, name: 'index_tags_on_name'
    add_index :tags, :name, unique: true

    ActsAsTaggableOn::Tag.find_each do |tag|
      ActsAsTaggableOn::Tag.reset_counters(tag.id, :taggings)
    end
  end

  def self.down
    drop_table :taggings
    drop_table :tags
  end
end
