class AddUserToHost < ActiveRecord::Migration[5.0]
  def change
    add_reference :hosts, :user, index: true, foreign_key: true
  end
end
