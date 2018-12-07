class CreateHostMachines < ActiveRecord::Migration[5.0]
  def change
    create_table :host_machines do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
