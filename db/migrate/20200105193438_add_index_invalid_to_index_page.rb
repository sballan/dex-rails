class AddIndexInvalidToIndexPage < ActiveRecord::Migration[6.0]
  def change
    add_column :index_pages, :index_invalid, :datetime
  end
end
