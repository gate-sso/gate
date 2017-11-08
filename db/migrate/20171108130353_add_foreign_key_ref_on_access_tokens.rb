class AddForeignKeyRefOnAccessTokens < ActiveRecord::Migration
  def change
     add_foreign_key "access_tokens", "users"
  end
end
