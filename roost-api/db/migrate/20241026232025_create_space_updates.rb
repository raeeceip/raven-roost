class CreateSpaceUpdates < ActiveRecord::Migration[7.1]
  def change
    create_table :space_updates, id: :uuid do |t|
      t.references :space, null: false, foreign_key: true, type: :uuid
      t.integer :occupancy
      t.string :status
      t.string :source
      t.datetime :recorded_at

      t.timestamps
    end

    add_index :space_updates, :recorded_at
  end
end
