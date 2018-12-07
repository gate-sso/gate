class AddShellToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :shell, :string
  end
end
