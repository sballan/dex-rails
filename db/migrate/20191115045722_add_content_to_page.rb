class AddContentToPage < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :content, :text
  end
end
