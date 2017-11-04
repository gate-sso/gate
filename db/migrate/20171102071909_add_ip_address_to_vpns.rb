class AddIpAddressToVpns < ActiveRecord::Migration
  def change
    add_column :vpns, :ip_address, :string
  end
end
