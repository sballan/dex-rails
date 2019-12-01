# frozen_string_literal: true

class AddWordsMapToPage < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :words_map, :text
  end
end
