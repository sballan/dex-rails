class CreateJoinTableDocsPages < ActiveRecord::Migration[6.0]
  def change
    create_join_table :text_docs, :pages do |t|
      t.index [:text_doc_id, :page_id]
      t.index [:page_id, :text_doc_id]
    end
  end
end
