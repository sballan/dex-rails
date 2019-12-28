# frozen_string_literal: true

class DropBatchesPages < ActiveRecord::Migration[6.0]
  def change
    drop_table :batches_pages do |t|
      t.bigint 'batch_id', null: false, foreign_key: true
      t.bigint 'page_id', null: false, foreign_key: true
      t.index ['batch_id', 'page_id'], name: 'index_batches_pages_on_batch_id_and_page_id'
      t.index ['page_id', 'batch_id'], name: 'index_batches_pages_on_page_id_and_batch_id'
    end
  end
end
