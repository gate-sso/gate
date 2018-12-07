class CreateGroupAssociations < ActiveRecord::Migration[5.0]
  def change
    create_table :group_associations do |t|
      t.references :user
      t.references :group

      t.timestamps null: false
    end
  end
end
