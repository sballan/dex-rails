class CreateDocBases < ActiveRecord::Migration[6.0]
  def change
    create_table :doc_bases do |t|
      t.string :value

      t.timestamps
    end
  end
end
