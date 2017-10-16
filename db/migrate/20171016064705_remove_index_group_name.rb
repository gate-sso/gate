class RemoveIndexGroupName < ActiveRecord::Migration
  def change
    remove_index :groups, [:name]
  end
end
