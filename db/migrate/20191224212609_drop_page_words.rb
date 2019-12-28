# frozen_string_literal: true

class DropPageWords < ActiveRecord::Migration[6.0]
  def change
    drop_table :page_words do |t|
      t.bigint 'page_id', null: false, foreign_key: true
      t.bigint 'word_id', null: false, foreign_key: true
      t.integer 'page_count'
      t.datetime 'created_at', precision: 6, null: false
      t.datetime 'updated_at', precision: 6, null: false
      t.jsonb 'data', default: { 'next_ids' => [], 'prev_ids' => [], 'word_count' => nil, 'all_indexes' => [], 'first_index' => nil, 'total_word_count' => nil }
      t.index ['page_id'], name: 'index_page_words_on_page_id'
      t.index ['word_id', 'page_id'], name: 'index_page_words_on_word_id_and_page_id', unique: true
      t.index ['word_id'], name: 'index_page_words_on_word_id'
    end
  end
end
