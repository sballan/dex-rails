class CreateIndexPageWordIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :index_page_words, %i[index_word_id index_page_id], unique: true
  end
end
