class AddUserToHost < ActiveRecord::Migration
  def change
    add_reference :hosts, :user, index: true, foreign_key: true
  end
end
