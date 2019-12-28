# frozen_string_literal: true

class CreateIndexHosts < ActiveRecord::Migration[6.0]
  def change
    create_table :index_hosts do |t|
      t.text :url_string

      t.timestamps
    end
    add_index :index_hosts, :url_string, unique: true
  end
end
