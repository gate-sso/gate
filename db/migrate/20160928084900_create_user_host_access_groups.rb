class CreateUserHostAccessGroups < ActiveRecord::Migration
  def change
    create_table :user_host_access_groups do |t|
      t.references :user, index: true, foreign_key: true
      t.references :host_access_group, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
