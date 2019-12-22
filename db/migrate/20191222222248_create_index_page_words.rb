class CreateIndexPageWords < ActiveRecord::Migration[6.0]
  def change
    create_table :index_page_words do |t|
      t.references :index_page, null: false, foreign_key: true
      t.references :index_word, null: false, foreign_key: true
      t.jsonb :data

      t.timestamps
    end
  end
end
