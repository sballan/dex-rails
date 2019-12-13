# frozen_string_literal: true

class IndexingBatch
  class ParseJob < ApplicationJob
    queue_as :parsing

    # @param [::IndexingBatch] batch
    def perform(batch, page)
      batch.parse_page(page)
      IndexJob.perform_later(batch, page)
    end
  end
end
