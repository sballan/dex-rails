# frozen_string_literal: true

class AddDownloadFailureToPage < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :download_failure, :datetime
  end
end
