class RemoveUrlFromVpns < ActiveRecord::Migration[5.0]
  def change
    remove_column :vpns, :url, :string
  end
end
