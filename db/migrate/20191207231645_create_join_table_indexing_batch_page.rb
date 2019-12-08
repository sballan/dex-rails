class CreateJoinTableIndexingBatchPage < ActiveRecord::Migration[6.0]
  def change
    create_join_table :indexing_batches, :pages do |t|
      t.index [:indexing_batch_id, :page_id]
      t.index [:page_id, :indexing_batch_id]
    end
  end
end
