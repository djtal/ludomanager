class AddHomePageToAuthors < ActiveRecord::Migration
  def self.up
    add_column :authors, :homepage, :string
  end

  def self.down
    remove_column :authors, :homepage
  end
end
