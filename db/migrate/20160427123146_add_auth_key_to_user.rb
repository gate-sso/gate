class AddAuthKeyToUser < ActiveRecord::Migration
  def change
    add_column :users, :auth_key, :string
  end
end
