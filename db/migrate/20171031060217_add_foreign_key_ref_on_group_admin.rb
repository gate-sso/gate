class AddForeignKeyRefOnGroupAdmin < ActiveRecord::Migration
  def change
    add_foreign_key :group_admins, :groups
    add_foreign_key :group_admins, :users
  end
end
