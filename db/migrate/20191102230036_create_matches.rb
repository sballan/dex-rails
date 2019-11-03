class CreateMatches < ActiveRecord::Migration[6.0]
  def change
    create_table :matches do |t|
      t.references :query, null: true, foreign_key: true
      t.references :doc, null: true, foreign_key: true
      t.references :page, null: true, foreign_key: true

      t.timestamps
    end
  end
end
