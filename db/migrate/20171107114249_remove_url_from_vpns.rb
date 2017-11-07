class RemoveUrlFromVpns < ActiveRecord::Migration
  def change
    remove_column :vpns, :url, :string
  end
end
