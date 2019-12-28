# frozen_string_literal: true

class DropPages < ActiveRecord::Migration[6.0]
  def change
    drop_table :pages do |t|
      t.string 'url_string'
      t.bigint 'host_id', null: false, foreign_key: true
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
  end
end
