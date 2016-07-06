class CreateGroupAssociations < ActiveRecord::Migration
  def change
    create_table :group_associations do |t|
      t.references :user
      t.references :group

      t.timestamps null: false
    end
  end
end
