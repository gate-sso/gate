class CreateHostMachines < ActiveRecord::Migration
  def change
    create_table :host_machines do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
