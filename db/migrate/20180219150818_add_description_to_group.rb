class AddDescriptionToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :description, :string
  end
end
