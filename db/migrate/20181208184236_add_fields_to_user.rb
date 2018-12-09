class AddFieldsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :user_role, :string
    add_column :users, :mobile, :string
    add_column :users, :alternate_email, :string
  end
end
