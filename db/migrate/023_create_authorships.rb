class CreateAuthorships < ActiveRecord::Migration
  def self.up
    create_table :authorships do |t|
      t.column :author_id, :integer
      t.column :game_id, :integer
    end
  end

  def self.down
    drop_table :authorships
  end
end
