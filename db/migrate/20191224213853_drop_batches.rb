# frozen_string_literal: true

class DropBatches < ActiveRecord::Migration[6.0]
  def change
    drop_table :batches do |t|
      t.datetime 'started_at'
      t.datetime 'stopped_at'
      t.datetime 'failed_at'
      t.datetime 'successful_at'
      t.jsonb 'data'
      t.datetime 'created_at', precision: 6, null: false
      t.datetime 'updated_at', precision: 6, null: false
      t.string 'type'
      t.index ['type'], name: 'index_batches_on_type'
    end
  end
end
