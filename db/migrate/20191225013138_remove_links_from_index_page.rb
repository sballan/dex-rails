# frozen_string_literal: true

class RemoveLinksFromIndexPage < ActiveRecord::Migration[6.0]
  def change
    remove_column :index_pages, :links, :text, array: true
  end
end
