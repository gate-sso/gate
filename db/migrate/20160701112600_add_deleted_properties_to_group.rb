class AddDeletedPropertiesToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :deleted_by, :integer
    add_column :groups, :deleted_at, :datetime
  end
end
