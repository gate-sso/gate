class CreateVpnGroupUserAssociation < ActiveRecord::Migration
  def change
    create_table :vpn_group_user_associations do |t|
      t.integer :user_id
      t.integer :vpn_id
      t.integer :group_id

      t.timestamps
    end
  end
end
