class CreateIndexingBatches < ActiveRecord::Migration[6.0]
  def change
    create_table :indexing_batches do |t|
      t.datetime :started_at
      t.datetime :stopped_at
      t.datetime :failed_at
      t.datetime :successful_at

      t.timestamps
    end
  end
end
