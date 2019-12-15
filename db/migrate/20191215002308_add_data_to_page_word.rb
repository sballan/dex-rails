# frozen_string_literal: true

class AddDataToPageWord < ActiveRecord::Migration[6.0]
  def change
    add_column :page_words, :data, :jsonb, default: {
      word_count: nil,
      total_word_count: nil,
      first_index: nil,
      all_indexes: [],
      next_ids: [],
      prev_ids: []
    }
  end
end
