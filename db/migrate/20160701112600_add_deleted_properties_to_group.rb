class AddDeletedPropertiesToGroup < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :deleted_by, :integer
    add_column :groups, :deleted_at, :datetime
  end
end
