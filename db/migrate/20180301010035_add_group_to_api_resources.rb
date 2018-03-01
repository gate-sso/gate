class AddGroupToApiResources < ActiveRecord::Migration
  def change
    add_reference :api_resources, :group, index: true, foreign_key: true
  end
end
