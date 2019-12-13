# frozen_string_literal: true

class CreateJoinTableIndexingBatchPage < ActiveRecord::Migration[6.0]
  def change
    create_join_table :indexing_batches, :pages do |t|
      t.index %i[indexing_batch_id page_id]
      t.index %i[page_id indexing_batch_id]
    end
  end
end
