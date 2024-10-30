
# db/migrate/XXXXXX_create_study_spaces.rb
class CreateStudySpaces < ActiveRecord::Migration[7.1]
  def change
    create_table :study_spaces do |t|
      t.string :name, null: false
      t.references :building, null: false, foreign_key: true
      t.integer :capacity, null: false, default: 0
      t.string :status, default: 'available'
      t.text :description
      t.string :room_number
      t.json :amenities
      t.integer :noise_level, default: 0

      t.timestamps
      
      t.index [:building_id, :room_number], unique: true
    end
  end
end
