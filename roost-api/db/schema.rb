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

ActiveRecord::Schema[7.1].define(version: 2024_10_27_100646) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "bookings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "space_id", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.string "status", default: "pending"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["space_id", "start_time", "end_time"], name: "index_bookings_on_space_id_and_start_time_and_end_time"
    t.index ["space_id"], name: "index_bookings_on_space_id"
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "building_hours", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "building", null: false
    t.integer "day_of_week", null: false
    t.time "opens_at", null: false
    t.time "closes_at", null: false
    t.boolean "is_closed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building", "day_of_week"], name: "index_building_hours_on_building_and_day_of_week", unique: true
  end

  create_table "favorite_spaces", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "space_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["space_id"], name: "index_favorite_spaces_on_space_id"
    t.index ["user_id", "space_id"], name: "index_favorite_spaces_on_user_id_and_space_id", unique: true
    t.index ["user_id"], name: "index_favorite_spaces_on_user_id"
  end

  create_table "jwt_denylist", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti"
  end

  create_table "space_amenities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "space_id", null: false
    t.string "name", null: false
    t.string "description"
    t.boolean "available", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["space_id", "name"], name: "index_space_amenities_on_space_id_and_name", unique: true
    t.index ["space_id"], name: "index_space_amenities_on_space_id"
  end

  create_table "space_updates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "space_id", null: false
    t.integer "occupancy"
    t.string "status"
    t.string "source"
    t.datetime "recorded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recorded_at"], name: "index_space_updates_on_recorded_at"
    t.index ["space_id"], name: "index_space_updates_on_space_id"
  end

  create_table "spaces", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "building", null: false
    t.integer "capacity", null: false
    t.integer "current_occupancy", default: 0
    t.string "status", default: "available"
    t.jsonb "amenities", default: {}
    t.datetime "last_updated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building"], name: "index_spaces_on_building"
    t.index ["status"], name: "index_spaces_on_status"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "role", default: "user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "provider"
    t.string "uid"
    t.string "access_token"
    t.string "refresh_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bookings", "spaces"
  add_foreign_key "bookings", "users"
  add_foreign_key "favorite_spaces", "spaces"
  add_foreign_key "favorite_spaces", "users"
  add_foreign_key "space_amenities", "spaces"
  add_foreign_key "space_updates", "spaces"
end
