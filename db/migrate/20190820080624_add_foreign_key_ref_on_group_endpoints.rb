class AddForeignKeyRefOnGroupEndpoints < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :group_endpoints, :groups
    add_foreign_key :group_endpoints, :endpoints
  end
end
