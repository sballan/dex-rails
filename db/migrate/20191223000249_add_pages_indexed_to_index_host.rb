# frozen_string_literal: true

class AddPagesIndexedToIndexHost < ActiveRecord::Migration[6.0]
  def change
    add_column :index_hosts, :pages_indexed, :bigint, array: true, default: []
  end
end
