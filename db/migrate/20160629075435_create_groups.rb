class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.integer :gid

      t.timestamps null: false
    end
    add_index :groups, :name
  end
end
