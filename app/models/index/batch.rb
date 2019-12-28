# frozen_string_literal: true

class Index::Batch < ApplicationRecord
  has_many :batch_pages, class_name: 'Index::BatchPage', foreign_key: :index_batch_id, dependent: :destroy
  has_many :pages, class_name: 'Index::Page', through: :batch_pages

  def run_now
    batch_pages.not_fetched.in_batches(of: 1).each_record do |record|
      begin
        record.fetch_page
      rescue => e
        Rails.logger.error(e.message)
        record.download_failure = DateTime.now.utc
        record.save
      end

      begin
        record.index_page
      rescue => e
        Rails.logger.error(e.message)
        record.index_failure = DateTime.now.utc
        record.save
      end
    end
  end
end
