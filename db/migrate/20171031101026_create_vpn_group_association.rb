class CreateVpnGroupAssociation < ActiveRecord::Migration
  def change
    create_table :vpn_group_associations do |t|
      t.integer :group_id
      t.integer :vpn_id

      t.timestamps
    end
  end
end
