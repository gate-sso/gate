class RenameAccessKeyInApiResources < ActiveRecord::Migration
  def change
    rename_column :api_resources, :access_key, :hashed_access_key
  end
end
