class AddUserLoginIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :user_login_id, :string
    add_index :users, :user_login_id
  end
end
