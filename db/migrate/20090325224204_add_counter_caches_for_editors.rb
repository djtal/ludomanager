class AddCounterCachesForEditors < ActiveRecord::Migration
  def self.up
    add_column :editors, :editions_count, :integer, :default => 0
    
    Editor.reset_column_information
    Editor.find(:all).each do |e|
      Editor.update_counters e.id, :editions_count => e.editions.length
    end
  end

  def self.down
    add_column :editors, :editions_count
  end
end
