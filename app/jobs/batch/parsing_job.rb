# frozen_string_literal: true

class Batch
  class ParsingJob < ApplicationJob
    queue_as :parsing

    # @param [::IndexingBatch] batch
    def perform(batch, page)
      batch.parse_page(page)
      IndexingJob.perform_later(batch, page)
    end
  end
end
