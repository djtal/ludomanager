class AddCommentAuthor < ActiveRecord::Migration
  def self.up
    add_column :comments, :author_name, :string
  end

  def self.down
    remove_column :comments, :author_name
  end
end
