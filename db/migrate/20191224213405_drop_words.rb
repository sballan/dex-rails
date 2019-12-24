# frozen_string_literal: true

class DropWords < ActiveRecord::Migration[6.0]
  def change
    drop_table :words do |t|
      t.string 'value'
      t.datetime 'created_at', precision: 6, null: false
      t.datetime 'updated_at', precision: 6, null: false
      t.index ['value'], name: 'index_words_on_value', unique: true
    end
  end
end
