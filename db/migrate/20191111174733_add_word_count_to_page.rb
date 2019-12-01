# frozen_string_literal: true

class AddWordCountToPage < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :word_count, :integer
  end
end
