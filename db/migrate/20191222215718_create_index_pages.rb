class CreateIndexPages < ActiveRecord::Migration[6.0]
  def change
    create_table :index_pages do |t|
      t.text :url_string
      t.references :index_host, null: false, foreign_key: true
      t.text :links, array: true
      t.datetime :download_success
      t.datetime :download_failure
      t.datetime :download_invalid
      t.jsonb :data

      t.timestamps
    end
    add_index :index_pages, :url_string, unique: true
  end
end
