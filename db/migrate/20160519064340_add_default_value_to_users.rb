class AddDefaultValueToUsers < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :active, :boolean, default: true
  end
end
