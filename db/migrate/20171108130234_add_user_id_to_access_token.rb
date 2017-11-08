class AddUserIdToAccessToken < ActiveRecord::Migration
  def change
    add_column :access_tokens, :user_id, :integer
  end
end
