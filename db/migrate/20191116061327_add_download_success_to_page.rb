class AddDownloadSuccessToPage < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :download_success, :datetime
  end
end
