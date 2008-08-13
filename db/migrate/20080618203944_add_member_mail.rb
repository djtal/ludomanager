class AddMemberMail < ActiveRecord::Migration
  def self.up
    add_column :members, :email, :text
  end

  def self.down
    remove_column :members, :email
  end
end
