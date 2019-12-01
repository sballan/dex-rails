# frozen_string_literal: true

class CreatePages < ActiveRecord::Migration[6.0]
  def change
    create_table :pages do |t|
      t.string :url_string
      t.references :host, null: false, foreign_key: true

      t.timestamps
    end
    add_index :pages, :url_string, unique: true
  end
end
