class AddTypeToDocBase < ActiveRecord::Migration[6.0]
  def change
    add_column :doc_bases, :type, :string
  end
end
