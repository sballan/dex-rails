# frozen_string_literal: true

class AddTypeToBatch < ActiveRecord::Migration[6.0]
  def change
    add_column :batches, :type, :string
    add_index :batches, :type
  end
end
