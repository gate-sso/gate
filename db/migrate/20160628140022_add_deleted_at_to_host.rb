class AddDeletedAtToHost < ActiveRecord::Migration
  def change
    add_column :hosts, :deleted_at, :datetime
    add_index :hosts, :deleted_at
  end
end
