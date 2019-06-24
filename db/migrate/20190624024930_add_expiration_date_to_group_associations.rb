class AddExpirationDateToGroupAssociations < ActiveRecord::Migration[5.1]
  def change
    add_column :group_associations, :expiration_date, :date
  end
end
