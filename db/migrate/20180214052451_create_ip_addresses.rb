class CreateIpAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :ip_addresses do |t|
      t.string :address
      t.string :mac_address

      t.timestamps null: false
    end
    add_index :ip_addresses, :address
    add_index :ip_addresses, :mac_address
  end
end
