class CreateQueries < ActiveRecord::Migration[6.0]
  def change
    create_table :queries do |t|
      t.string :value

      t.timestamps
    end
    add_index :queries, :value
  end
end
