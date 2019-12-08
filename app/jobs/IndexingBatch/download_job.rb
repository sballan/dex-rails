class IndexingBatch
  class DownloadJob < ApplicationJob
    queue_as :downloading

    # @param [::IndexingBatch] batch
    def perform(batch, page)
      batch.download_page(page)
      ParseJob.perform_later(batch, page)
    end
  end
end