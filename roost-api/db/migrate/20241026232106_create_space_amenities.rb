class CreateSpaceAmenities < ActiveRecord::Migration[7.1]
  def change
    create_table :space_amenities, id: :uuid do |t|
      t.references :space, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :description
      t.boolean :available, default: true

      t.timestamps
    end

    add_index :space_amenities, [:space_id, :name], unique: true
  end
end
