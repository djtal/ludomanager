class AddGameTestAuthor < ActiveRecord::Migration
  def self.up
    add_column :games, :author, :string
  end

  def self.down
    remove_column :games, :author
  end
end
