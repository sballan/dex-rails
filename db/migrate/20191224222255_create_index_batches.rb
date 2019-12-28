# frozen_string_literal: true

class CreateIndexBatches < ActiveRecord::Migration[6.0]
  def change
    create_table :index_batches, &:timestamps
  end
end
