class CreateBuildingHours < ActiveRecord::Migration[7.1]
  def change
    create_table :building_hours, id: :uuid do |t|
      t.string :building, null: false
      t.integer :day_of_week, null: false
      t.time :opens_at, null: false
      t.time :closes_at, null: false
      t.boolean :is_closed, default: false

      t.timestamps
    end

    add_index :building_hours, [:building, :day_of_week], unique: true
  end
end
