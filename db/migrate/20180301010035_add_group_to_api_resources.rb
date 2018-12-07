class AddGroupToApiResources < ActiveRecord::Migration[5.0]
  def change
    add_reference :api_resources, :group, index: true, foreign_key: true
  end
end
