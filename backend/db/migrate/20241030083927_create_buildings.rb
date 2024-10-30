class CreateBuildings < ActiveRecord::Migration[7.1]
  def change
    create_table :buildings do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.text :description
      t.string :image_url

      t.timestamps
      
      t.index :code, unique: true
    end
  end
end
