class CreateVpnGroupAssociation < ActiveRecord::Migration[5.0]
  def change
    create_table :vpn_group_associations do |t|
      t.integer :group_id
      t.integer :vpn_id

      t.timestamps
    end
  end
end
