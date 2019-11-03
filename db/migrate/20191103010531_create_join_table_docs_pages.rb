class CreateJoinTableDocsPages < ActiveRecord::Migration[6.0]
  def change
    create_join_table :docs, :pages do |t|
      t.index [:doc_id, :page_id]
      t.index [:page_id, :doc_id]
    end
  end
end
