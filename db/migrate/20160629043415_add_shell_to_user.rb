class AddShellToUser < ActiveRecord::Migration
  def change
    add_column :users, :shell, :string
  end
end
