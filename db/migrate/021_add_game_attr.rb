class AddGameAttr < ActiveRecord::Migration
  def self.up
    add_column :games, :publish_year, :string
    add_column :games, :editor, :string
  end

  def self.down
    remove_column :games, :publish_year
    remove_column :games, :editor
  end
end
