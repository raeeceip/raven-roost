class CreateFavoriteSpaces < ActiveRecord::Migration[7.1]
  def change
    create_table :favorite_spaces, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :space, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :favorite_spaces, [:user_id, :space_id], unique: true
  end
end
