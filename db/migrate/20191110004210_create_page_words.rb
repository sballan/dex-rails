class CreatePageWords < ActiveRecord::Migration[6.0]
  def change
    create_table :page_words do |t|
      t.references :page, null: false, foreign_key: true
      t.references :word, null: false, foreign_key: true
      t.integer :page_count

      t.timestamps
    end
  end
end
