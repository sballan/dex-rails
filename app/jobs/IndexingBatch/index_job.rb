class IndexingBatch
  class IndexJob < ApplicationJob
    queue_as :indexing

    # @param [::IndexingBatch] batch
    def perform(batch, page)
      batch.index_page(page)
      batch.stop!
      batch.succeed!
    end
  end
end