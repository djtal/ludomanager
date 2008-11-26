class AddLangToEditor < ActiveRecord::Migration
  def self.up
    add_column :editors, :lang, :text
  end

  def self.down
    remove_column :editors, :lang
  end
end
