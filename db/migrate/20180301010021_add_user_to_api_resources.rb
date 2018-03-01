class AddUserToApiResources < ActiveRecord::Migration
  def change
    add_reference :api_resources, :user, index: true, foreign_key: true
  end
end
