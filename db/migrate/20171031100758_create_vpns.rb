class CreateVpns < ActiveRecord::Migration[5.0]
  def change
    create_table :vpns do |t|
      t.string :name
      t.string :host_name
      t.string :url

      t.timestamps
    end
  end
end
