class AddIpAddressToVpns < ActiveRecord::Migration[5.0]
  def change
    add_column :vpns, :ip_address, :string
  end
end
