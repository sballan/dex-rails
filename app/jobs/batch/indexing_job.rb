# frozen_string_literal: true

class Batch
  class IndexingJob < ApplicationJob
    queue_as :indexing

    # @param [::IndexingBatch] batch
    def perform(batch, page)
      batch.index_page(page)
    end
  end
end
