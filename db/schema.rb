# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_09_193835) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "hosts", force: :cascade do |t|
    t.string "host_url_string"
    t.integer "limit_time", default: 5
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["host_url_string"], name: "index_hosts_on_host_url_string", unique: true
  end

  create_table "pages", force: :cascade do |t|
    t.string "url_string"
    t.bigint "host_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["host_id"], name: "index_pages_on_host_id"
    t.index ["url_string"], name: "index_pages_on_url_string", unique: true
  end

  add_foreign_key "pages", "hosts"
end
