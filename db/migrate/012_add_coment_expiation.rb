class AddComentExpiation < ActiveRecord::Migration
  def self.up
    add_column :games, :comment_age, :integer, :default => 0
    add_column :articles, :comment_age, :integer, :default => 30
  end

  def self.down
    remove_column :games, :comment_age
    remove_column :articles, :comment_age
  end
end
