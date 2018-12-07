class AddAuthKeyToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :auth_key, :string
  end
end
