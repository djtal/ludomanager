class AddAccountGameAttr < ActiveRecord::Migration
  def self.up
    add_column :account_games, :origin, :text
    add_column :account_games, :price, :float
    add_column :account_games, :transdate, :datetime
    AccountGame.reset_column_information
    AccountGame.find(:all).each do |a| 
      a.transdate = a.created_at
      a.save
    end
  end

  def self.down
    remove_column :account_games, :origin
    remove_column :account_games, :price
    remove_column :account_games, :transdate
  end
end
