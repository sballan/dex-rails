# frozen_string_literal: true

class Batch
  class DownloadJob < ApplicationJob
    queue_as :downloading

    discard_on Page::BadCrawl

    rescue_from(Page::LimitReached) do
      retry_job queue: :downloading, wait: Random.rand((1.second)..(1.minute))
    end

    # @param [::IndexingBatch] batch
    def perform(batch, page)
      batch.download_page(page)
      ParsingJob.perform_later(batch, page)
    end
  end
end
