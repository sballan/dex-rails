# frozen_string_literal: true

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

ActiveRecord::Schema.define(version: 20_191_206_023_160) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'hosts', force: :cascade do |t|
    t.string 'host_url_string'
    t.integer 'limit_time', default: 5
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.integer 'failure_retry_seconds', default: 300
    t.integer 'invalid_retry_seconds', default: 86_400
    t.integer 'success_retry_seconds', default: 10
    t.index ['host_url_string'], name: 'index_hosts_on_host_url_string', unique: true
  end

  create_table 'page_words', force: :cascade do |t|
    t.bigint 'page_id', null: false
    t.bigint 'word_id', null: false
    t.integer 'page_count'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['page_id'], name: 'index_page_words_on_page_id'
    t.index %w[word_id page_id], name: 'index_page_words_on_word_id_and_page_id', unique: true
    t.index ['word_id'], name: 'index_page_words_on_word_id'
  end

  create_table 'pages', force: :cascade do |t|
    t.string 'url_string'
    t.bigint 'host_id', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.text 'links'
    t.integer 'word_count'
    t.text 'words_map'
    t.text 'content'
    t.datetime 'download_success'
    t.datetime 'download_failure'
    t.datetime 'download_invalid'
    t.index ['host_id'], name: 'index_pages_on_host_id'
    t.index ['url_string'], name: 'index_pages_on_url_string', unique: true
  end

  create_table 'queries', force: :cascade do |t|
    t.string 'value'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['value'], name: 'index_queries_on_value'
  end

  create_table 'words', force: :cascade do |t|
    t.string 'value'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['value'], name: 'index_words_on_value', unique: true
  end

  add_foreign_key 'page_words', 'pages'
  add_foreign_key 'page_words', 'words'
  add_foreign_key 'pages', 'hosts'
end
