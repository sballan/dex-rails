# frozen_string_literal: true

class CreateIndexBatchPages < ActiveRecord::Migration[6.0]
  def change
    create_table :index_batch_pages do |t|
      t.references :index_batch, null: false, foreign_key: true
      t.references :index_page, null: false, foreign_key: true
      t.datetime :download_success
      t.datetime :download_failure
      t.datetime :index_success
      t.datetime :index_failure

      t.timestamps
    end
  end
end
