class AddDescriptionToGroup < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :description, :string
  end
end
