class CreateTextDocs < ActiveRecord::Migration[6.0]
  def change
    create_table :text_docs do |t|
      t.string :value

      t.timestamps
    end
  end
end
