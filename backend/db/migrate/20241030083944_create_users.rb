

# db/migrate/XXXXXX_create_users.rb
class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :role, default: 'student'
      t.string :google_uid
      t.string :avatar_url

      t.timestamps
      
      t.index :email, unique: true
      t.index :google_uid, unique: true
    end
  end
end
