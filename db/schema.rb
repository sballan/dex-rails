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

ActiveRecord::Schema.define(version: 2019_12_22_215718) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "batches", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "stopped_at"
    t.datetime "failed_at"
    t.datetime "successful_at"
    t.jsonb "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type"
    t.index ["type"], name: "index_batches_on_type"
  end

  create_table "batches_pages", id: false, force: :cascade do |t|
    t.bigint "batch_id", null: false
    t.bigint "page_id", null: false
    t.index ["batch_id", "page_id"], name: "index_batches_pages_on_batch_id_and_page_id"
    t.index ["page_id", "batch_id"], name: "index_batches_pages_on_page_id_and_batch_id"
  end

  create_table "hosts", force: :cascade do |t|
    t.string "host_url_string"
    t.integer "limit_time", default: 5
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "failure_retry_seconds", default: 300
    t.integer "invalid_retry_seconds", default: 86400
    t.integer "success_retry_seconds", default: 10
    t.index ["host_url_string"], name: "index_hosts_on_host_url_string", unique: true
  end

  create_table "index_hosts", force: :cascade do |t|
    t.text "url_string"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["url_string"], name: "index_index_hosts_on_url_string", unique: true
  end

  create_table "index_pages", force: :cascade do |t|
    t.text "url_string"
    t.bigint "index_host_id", null: false
    t.text "links", array: true
    t.datetime "download_success"
    t.datetime "download_failure"
    t.datetime "download_invalid"
    t.jsonb "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["index_host_id"], name: "index_index_pages_on_index_host_id"
    t.index ["url_string"], name: "index_index_pages_on_url_string", unique: true
  end

  create_table "indexing_batches", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "stopped_at"
    t.datetime "failed_at"
    t.datetime "successful_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "indexing_batches_pages", id: false, force: :cascade do |t|
    t.bigint "indexing_batch_id", null: false
    t.bigint "page_id", null: false
    t.index ["indexing_batch_id", "page_id"], name: "index_indexing_batches_pages_on_indexing_batch_id_and_page_id"
    t.index ["page_id", "indexing_batch_id"], name: "index_indexing_batches_pages_on_page_id_and_indexing_batch_id"
  end

  create_table "page_words", force: :cascade do |t|
    t.bigint "page_id", null: false
    t.bigint "word_id", null: false
    t.integer "page_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "data", default: {"next_ids"=>[], "prev_ids"=>[], "word_count"=>nil, "all_indexes"=>[], "first_index"=>nil, "total_word_count"=>nil}
    t.index ["page_id"], name: "index_page_words_on_page_id"
    t.index ["word_id", "page_id"], name: "index_page_words_on_word_id_and_page_id", unique: true
    t.index ["word_id"], name: "index_page_words_on_word_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "url_string"
    t.bigint "host_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "links"
    t.integer "word_count"
    t.text "words_map"
    t.text "content"
    t.datetime "download_success"
    t.datetime "download_failure"
    t.datetime "download_invalid"
    t.index ["host_id"], name: "index_pages_on_host_id"
    t.index ["url_string"], name: "index_pages_on_url_string", unique: true
  end

  create_table "queries", force: :cascade do |t|
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["value"], name: "index_queries_on_value"
  end

  create_table "words", force: :cascade do |t|
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["value"], name: "index_words_on_value", unique: true
  end

  add_foreign_key "index_pages", "index_hosts"
  add_foreign_key "page_words", "pages"
  add_foreign_key "page_words", "words"
  add_foreign_key "pages", "hosts"
end
