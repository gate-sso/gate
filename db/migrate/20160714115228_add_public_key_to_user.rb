class AddPublicKeyToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :public_key, :text
  end
end
