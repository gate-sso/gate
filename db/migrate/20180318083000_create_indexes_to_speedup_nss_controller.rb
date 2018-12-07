class CreateIndexesToSpeedupNssController < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :uid
    add_index :access_tokens, :hashed_token
    add_index :host_machines, :access_key
    add_index :host_access_groups, [:host_machine_id, :group_id]
    add_index :group_associations, [:group_id, :user_id]
    add_index :groups, :gid
  end
end
