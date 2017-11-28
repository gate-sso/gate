class CreateVpnDomainNameServers < ActiveRecord::Migration
  def change
    create_table :vpn_domain_name_servers do |t|
      t.integer :vpn_id
      t.string :server_address

      t.timestamps
    end
  end
end
