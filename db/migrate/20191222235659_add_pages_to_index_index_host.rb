# frozen_string_literal: true

class AddPagesToIndexIndexHost < ActiveRecord::Migration[6.0]
  def change
    add_column :index_hosts, :pages_to_index, :bigint, array: true, default: []
  end
end
