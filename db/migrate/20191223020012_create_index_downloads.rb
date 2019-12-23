class CreateIndexDownloads < ActiveRecord::Migration[6.0]
  def change
    create_table :index_downloads do |t|
      t.references :index_page, null: false, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end
  end
end
