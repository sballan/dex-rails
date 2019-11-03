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

ActiveRecord::Schema.define(version: 2019_11_03_221042) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "docs", force: :cascade do |t|
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type"
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "query_id"
    t.bigint "doc_id"
    t.bigint "page_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["doc_id"], name: "index_matches_on_doc_id"
    t.index ["page_id"], name: "index_matches_on_page_id"
    t.index ["query_id"], name: "index_matches_on_query_id"
  end

  create_table "page_fragments", force: :cascade do |t|
    t.bigint "page_id", null: false
    t.bigint "doc_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["doc_id"], name: "index_page_fragments_on_doc_id"
    t.index ["page_id"], name: "index_page_fragments_on_page_id"
  end

  create_table "pages", force: :cascade do |t|
    t.bigint "url_id", null: false
    t.text "links"
    t.string "title"
    t.binary "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["url_id"], name: "index_pages_on_url_id"
  end

  create_table "queries", force: :cascade do |t|
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "urls", force: :cascade do |t|
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "matches", "docs"
  add_foreign_key "matches", "pages"
  add_foreign_key "matches", "queries"
  add_foreign_key "page_fragments", "docs"
  add_foreign_key "page_fragments", "pages"
  add_foreign_key "pages", "urls"
end
