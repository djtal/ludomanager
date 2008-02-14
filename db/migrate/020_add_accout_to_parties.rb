class AddAccoutToParties < ActiveRecord::Migration
  def self.up
    add_column :parties, :account_id, :integer
  end

  def self.down
    remove_column :parties, :account_id
  end
end
