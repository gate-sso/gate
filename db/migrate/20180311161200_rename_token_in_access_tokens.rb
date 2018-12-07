class RenameTokenInAccessTokens < ActiveRecord::Migration[5.0]
  def change
    rename_column :access_tokens, :token, :hashed_token
  end
end
