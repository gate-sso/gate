class CreateEndpoints < ActiveRecord::Migration[5.1]
  def change
    create_table :endpoints do |t|
      t.string :path, null: false
      t.string :method, null: false

      t.timestamps null: false
    end
  end
end
