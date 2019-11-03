class AddTypeToDoc < ActiveRecord::Migration[6.0]
  def change
    add_column :docs, :type, :string
  end
end
