class CreateSpaces < ActiveRecord::Migration[7.1]
  def change
    create_table :spaces, id: :uuid do |t|
      t.string :name, null: false
      t.string :building, null: false
      t.integer :capacity, null: false
      t.integer :current_occupancy, default: 0
      t.string :status, default: 'available'
      t.jsonb :amenities, default: {}
      t.datetime :last_updated

      t.timestamps
    end

    add_index :spaces, :building
    add_index :spaces, :status
  end
end
