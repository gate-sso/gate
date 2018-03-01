class CreateApiResources < ActiveRecord::Migration
  def change
    create_table :api_resources do |t|
      t.string :name
      t.string :description
      t.string :access_key

      t.timestamps null: false
    end
  end
end
