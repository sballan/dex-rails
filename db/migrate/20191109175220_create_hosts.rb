# frozen_string_literal: true

class CreateHosts < ActiveRecord::Migration[6.0]
  def change
    create_table :hosts do |t|
      t.string :host_url_string
      t.integer :limit_time, default: 5

      t.timestamps
    end
    add_index :hosts, :host_url_string, unique: true
  end
end
