class AddProductNameToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :product_name, :string
  end
end
