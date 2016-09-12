class CreateHostMachineGroups < ActiveRecord::Migration
  def change
    create_table :host_machine_groups do |t|
      t.references :user, index: true, foreign_key: true
      t.references :host_machine, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
