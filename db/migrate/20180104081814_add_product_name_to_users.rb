class AddProductNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :product_name, :string
  end
end
