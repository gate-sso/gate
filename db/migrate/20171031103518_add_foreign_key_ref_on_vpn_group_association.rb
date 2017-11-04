class AddForeignKeyRefOnVpnGroupAssociation < ActiveRecord::Migration
  def change
    add_foreign_key :vpn_group_associations, :groups
    add_foreign_key :vpn_group_associations, :vpns
  end
end
