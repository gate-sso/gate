class CreateHostAccessGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :host_access_groups do |t|
      t.references :host_machine
      t.references :group

      t.timestamps null: false
    end
  end
end
