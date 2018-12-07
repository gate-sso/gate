class AddUuidToVpns < ActiveRecord::Migration[5.0]
  def change
    add_column :vpns, :uuid, :string
  end
end
