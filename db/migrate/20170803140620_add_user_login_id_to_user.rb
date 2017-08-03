class AddUserLoginIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :user_login_id, :string
    add_index :users, :user_login_id
  end
end
