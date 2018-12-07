class CreateVpnDomainNameServers < ActiveRecord::Migration[5.0]
  def change
    create_table :vpn_domain_name_servers do |t|
      t.integer :vpn_id
      t.string :server_address

      t.timestamps
    end
  end
end
