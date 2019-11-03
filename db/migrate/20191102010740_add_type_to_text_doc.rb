class AddTypeToTextDoc < ActiveRecord::Migration[6.0]
  def change
    add_column :text_docs, :type, :string
  end
end
