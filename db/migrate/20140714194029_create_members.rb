class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.references:account
      t.string :first_name
      t.string :last_name
      t.boolean :active, default: true
      t.string :email

      t.timestamps
    end
  end
end
