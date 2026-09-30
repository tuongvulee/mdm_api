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

ActiveRecord::Schema[8.1].define(version: 2026_09_30_005911) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "devices", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "platform", null: false
    t.string "serial_number", null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["serial_number"], name: "index_devices_on_serial_number", unique: true
    t.index ["user_id"], name: "index_devices_on_user_id"
    t.check_constraint "platform::text = ANY (ARRAY['ios'::character varying, 'android'::character varying, 'windows'::character varying]::text[])", name: "devices_platform_check"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying]::text[])", name: "devices_status_check"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "devices", "users"
end
