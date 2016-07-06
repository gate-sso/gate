class AddDeletedByToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :deleted_by, :integer
    add_index :hosts, :deleted_by
  end
end
