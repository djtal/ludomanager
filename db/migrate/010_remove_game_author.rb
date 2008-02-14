class RemoveGameAuthor < ActiveRecord::Migration
  def self.up
    remove_column :games, :author
  end

  def self.down
    add_column :comments, :author_name, :string
  end
end
