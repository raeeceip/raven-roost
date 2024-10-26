class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :space, null: false, foreign_key: true, type: :uuid
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.string :status, default: 'pending'
      t.text :notes

      t.timestamps
    end

    add_index :bookings, [:space_id, :start_time, :end_time]
    add_index :bookings, :status
  end
end
