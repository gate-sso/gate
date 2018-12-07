class CreateHosts < ActiveRecord::Migration[5.0]
  def change
    create_table :hosts do |t|
      t.string :host_pattern

      t.timestamps null: false
    end
    add_index :hosts, :host_pattern
  end
end
