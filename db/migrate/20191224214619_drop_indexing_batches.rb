# frozen_string_literal: true

class DropIndexingBatches < ActiveRecord::Migration[6.0]
  def change
    drop_table :indexing_batches do |t|
      t.datetime 'started_at'
      t.datetime 'stopped_at'
      t.datetime 'failed_at'
      t.datetime 'successful_at'
      t.datetime 'created_at', precision: 6, null: false
      t.datetime 'updated_at', precision: 6, null: false
    end
  end
end
