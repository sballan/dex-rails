# frozen_string_literal: true

class CreateBatches < ActiveRecord::Migration[6.0]
  def change
    create_table :batches do |t|
      t.datetime :started_at
      t.datetime :stopped_at
      t.datetime :failed_at
      t.datetime :successful_at
      t.jsonb :data

      t.timestamps
    end
  end
end
