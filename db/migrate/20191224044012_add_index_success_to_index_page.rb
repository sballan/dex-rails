# frozen_string_literal: true

class AddIndexSuccessToIndexPage < ActiveRecord::Migration[6.0]
  def change
    add_column :index_pages, :index_success, :datetime
    add_column :index_pages, :index_failure, :datetime
  end
end
