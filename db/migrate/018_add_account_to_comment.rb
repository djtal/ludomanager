class AddAccountToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :account_id, :integer
    add_column :comments, :author_email, :string
    remove_column :comments, :author_id
  end

  def self.down
    remove_column :comments, :account_id
  end
end
