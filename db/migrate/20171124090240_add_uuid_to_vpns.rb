class AddUuidToVpns < ActiveRecord::Migration
  def change
    add_column :vpns, :uuid, :string
  end
end
