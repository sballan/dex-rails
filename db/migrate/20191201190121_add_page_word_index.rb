class AddPageWordIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :page_words, [:word_id, :page_id], unique: true
  end
end
