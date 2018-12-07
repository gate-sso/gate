class AddForeignKeyRefOnGroupAdmin < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :group_admins, :groups
    add_foreign_key :group_admins, :users
  end
end
