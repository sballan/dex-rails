# frozen_string_literal: true

class CreateJoinTableBatchPage < ActiveRecord::Migration[6.0]
  def change
    create_join_table :batches, :pages do |t|
      t.index %i[batch_id page_id]
      t.index %i[page_id batch_id]
    end
  end
end
