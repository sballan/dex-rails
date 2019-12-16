# frozen_string_literal: true

class IndexingBatch
  class IndexJob < ApplicationJob
    queue_as :indexing

    # @param [::IndexingBatch] batch
    def perform(batch, page)
      batch.index_page(page)
      GC.start(full_mark: true, immediate_sweep: true)
    end
  end
end
