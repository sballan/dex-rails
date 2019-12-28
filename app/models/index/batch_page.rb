# frozen_string_literal: true

class Index::BatchPage < ApplicationRecord
  belongs_to :batch, class_name: 'Index::Batch', foreign_key: :index_batch_id
  belongs_to :page, class_name: 'Index::Page', foreign_key: :index_page_id

  scope :not_downloaded, -> { where(download_success: nil) }
  scope :not_indexed, -> { where(index_success: nil) }

  def fetch_page
    old_downloads_count = page.downloads.count

    page.fetch_page

    if page.downloads.count == (old_downloads_count + 1)
      self[:download_success] = DateTime.now.utc
      save!
    end
  end

  def index_page
    page.index_page
    self[:index_success] = DateTime.now.utc
    save!
  end
end
