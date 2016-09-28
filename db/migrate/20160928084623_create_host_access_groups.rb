class CreateHostAccessGroups < ActiveRecord::Migration
  def change
    create_table :host_access_groups do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
