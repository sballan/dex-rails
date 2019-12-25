# frozen_string_literal: true

class CreateIndexWords < ActiveRecord::Migration[6.0]
  def change
    create_table :index_words do |t|
      t.text :value

      t.timestamps
    end
    add_index :index_words, :value, unique: true
  end
end
