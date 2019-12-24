# frozen_string_literal: true

class Index::BatchPage < ApplicationRecord
  belongs_to :batch, class_name: 'Index::Batch', foreign_key: :index_batch_id
  belongs_to :page, class_name: 'Index::Page', foreign_key: :index_page_id

  scope :not_downloaded, -> { where(download_success: nil) }
  scope :not_indexed, -> { where(index_success: nil) }
end
