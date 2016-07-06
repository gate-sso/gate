class AddHomedirToUser < ActiveRecord::Migration
  def change
    add_column :users, :home_dir, :string
  end
end
