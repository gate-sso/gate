class RenameAccessKeyInApiResources < ActiveRecord::Migration[5.0]
  def change
    rename_column :api_resources, :access_key, :hashed_access_key
  end
end
