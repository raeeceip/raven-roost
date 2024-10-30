# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_10_30_083954) do
  create_table "buildings", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.text "description"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_buildings_on_code", unique: true
  end

  create_table "favorites", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "study_space_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["study_space_id"], name: "index_favorites_on_study_space_id"
    t.index ["user_id", "study_space_id"], name: "index_favorites_on_user_id_and_study_space_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "study_spaces", force: :cascade do |t|
    t.string "name", null: false
    t.integer "building_id", null: false
    t.integer "capacity", default: 0, null: false
    t.string "status", default: "available"
    t.text "description"
    t.string "room_number"
    t.json "amenities"
    t.integer "noise_level", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id", "room_number"], name: "index_study_spaces_on_building_id_and_room_number", unique: true
    t.index ["building_id"], name: "index_study_spaces_on_building_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "role", default: "student"
    t.string "google_uid"
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_uid"], name: "index_users_on_google_uid", unique: true
  end

  add_foreign_key "favorites", "study_spaces"
  add_foreign_key "favorites", "users"
  add_foreign_key "study_spaces", "buildings"
end
