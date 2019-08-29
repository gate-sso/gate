class CreateGroupEndpoints < ActiveRecord::Migration[5.1]
  def change
    create_table :group_endpoints do |t|
      t.integer :group_id
      t.bigint :endpoint_id

      t.timestamps null: false
    end
  end
end
