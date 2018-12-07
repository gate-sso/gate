class CreateAccessTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :access_tokens do |t|
      t.string :token

      t.timestamps null: false
    end
  end
end
