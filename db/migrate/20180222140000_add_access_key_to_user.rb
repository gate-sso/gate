class AddAccessKeyToUser < ActiveRecord::Migration
  def change
    add_column :users, :access_key, :string
  end
end
