class RemoveIndexGroupName < ActiveRecord::Migration[5.0]
  def change
    remove_index :groups, [:name]
  end
end
