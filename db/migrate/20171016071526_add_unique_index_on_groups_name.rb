class AddUniqueIndexOnGroupsName < ActiveRecord::Migration[5.0]
  def change
    add_index :groups, :name, unique: true
  end
end
