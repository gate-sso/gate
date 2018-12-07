class CreateVpnSupplementalMatchDomains < ActiveRecord::Migration[5.0]
  def change
    create_table :vpn_supplemental_match_domains do |t|
      t.integer :vpn_id
      t.string :supplemental_match_domain

      t.timestamps
    end
  end
end
