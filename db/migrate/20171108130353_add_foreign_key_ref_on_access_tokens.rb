class AddForeignKeyRefOnAccessTokens < ActiveRecord::Migration[5.0]
  def change
     add_foreign_key "access_tokens", "users"
  end
end
