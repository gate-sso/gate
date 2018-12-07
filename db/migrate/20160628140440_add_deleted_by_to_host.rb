class AddDeletedByToHost < ActiveRecord::Migration[5.0]
  def change
    add_column :hosts, :deleted_by, :integer
    add_index :hosts, :deleted_by
  end
end
