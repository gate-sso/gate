class RenameTokenInAccessTokens < ActiveRecord::Migration
  def change
    rename_column :access_tokens, :token, :hashed_token
  end
end
