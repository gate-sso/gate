class CreateHostMachineAccessGroups < ActiveRecord::Migration
  def change
    create_table :host_machine_access_groups do |t|
      t.references :host_machine, index: true, foreign_key: true
      t.references :host_access_group, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
