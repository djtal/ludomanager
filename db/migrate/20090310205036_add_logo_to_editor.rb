class AddLogoToEditor < ActiveRecord::Migration
  def self.up
    add_column :editors, :logo_file_name,    :string
    add_column :editors, :logo_content_type, :string
    add_column :editors, :logo_file_size,    :integer
    add_column :editors, :logo_updated_at,   :datetime
  end

  def self.down
    remove_column :editors, :logo_file_name
    remove_column :editors, :logo_content_type
    remove_column :editors, :logo_file_size
    remove_column :editors, :logo_updated_at
  end

end
