# frozen_string_literal: true

class AddDownloadInvalidToPage < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :download_invalid, :datetime
  end
end
