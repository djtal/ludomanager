class AddLangToAuthor < ActiveRecord::Migration
  def self.up
    add_column :authors, :lang, :string, :default => ""
  end

  def self.down
    remove_column :authors, :lang
  end
end
