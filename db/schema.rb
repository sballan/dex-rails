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

ActiveRecord::Schema.define(version: 2019_12_28_055049) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "index_batch_pages", force: :cascade do |t|
    t.bigint "index_batch_id", null: false
    t.bigint "index_page_id", null: false
    t.datetime "download_success"
    t.datetime "download_failure"
    t.datetime "index_success"
    t.datetime "index_failure"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["index_batch_id"], name: "index_index_batch_pages_on_index_batch_id"
    t.index ["index_page_id"], name: "index_index_batch_pages_on_index_page_id"
  end

  create_table "index_batches", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "index_downloads", force: :cascade do |t|
    t.bigint "index_page_id", null: false
    t.text "content", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["index_page_id"], name: "index_index_downloads_on_index_page_id"
  end

  create_table "index_hosts", force: :cascade do |t|
    t.text "url_string"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "pages_to_index", default: [], array: true
    t.bigint "pages_indexed", default: [], array: true
    t.index ["url_string"], name: "index_index_hosts_on_url_string", unique: true
  end

  create_table "index_page_words", force: :cascade do |t|
    t.bigint "index_page_id", null: false
    t.bigint "index_word_id", null: false
    t.jsonb "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["index_page_id"], name: "index_index_page_words_on_index_page_id"
    t.index ["index_word_id", "index_page_id"], name: "index_index_page_words_on_index_word_id_and_index_page_id", unique: true
    t.index ["index_word_id"], name: "index_index_page_words_on_index_word_id"
  end

  create_table "index_pages", force: :cascade do |t|
    t.text "url_string"
    t.bigint "index_host_id", null: false
    t.datetime "download_success"
    t.datetime "download_failure"
    t.datetime "download_invalid"
    t.jsonb "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "index_success"
    t.datetime "index_failure"
    t.index ["index_host_id"], name: "index_index_pages_on_index_host_id"
    t.index ["url_string"], name: "index_index_pages_on_url_string", unique: true
  end

  create_table "index_words", force: :cascade do |t|
    t.text "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["value"], name: "index_index_words_on_value", unique: true
  end

  create_table "queries", force: :cascade do |t|
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["value"], name: "index_queries_on_value"
  end

  add_foreign_key "index_batch_pages", "index_batches"
  add_foreign_key "index_batch_pages", "index_pages"
  add_foreign_key "index_downloads", "index_pages"
  add_foreign_key "index_page_words", "index_pages"
  add_foreign_key "index_page_words", "index_words"
  add_foreign_key "index_pages", "index_hosts"
end
