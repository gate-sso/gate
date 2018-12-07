class AddUserIdToAccessToken < ActiveRecord::Migration[5.0]
  def change
    add_column :access_tokens, :user_id, :integer
  end
end
