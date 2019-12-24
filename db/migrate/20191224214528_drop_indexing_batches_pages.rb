# frozen_string_literal: true

class DropIndexingBatchesPages < ActiveRecord::Migration[6.0]
  def change
    drop_table :indexing_batches_pages do |t|
      t.bigint 'indexing_batch_id', null: false, foreign_key: true
      t.bigint 'page_id', null: false, foreign_key: true
      t.index ['indexing_batch_id', 'page_id'], name: 'index_indexing_batches_pages_on_indexing_batch_id_and_page_id'
      t.index ['page_id', 'indexing_batch_id'], name: 'index_indexing_batches_pages_on_page_id_and_indexing_batch_id'
    end
  end
end
