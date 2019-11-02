class CreatePages < ActiveRecord::Migration[6.0]
  def change
    create_table :pages do |t|
      t.references :url, null: false, foreign_key: true
      t.text :links
      t.string :title
      t.binary :body

      t.timestamps
    end
  end
end
