class AddHomedirToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :home_dir, :string
  end
end
