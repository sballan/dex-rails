# frozen_string_literal: true

module Index
  class AllPagesToIndexJob < ApplicationJob
    queue_as :indexing

    def perform(limit = nil)
      Index.all_pages_to_index(limit).in_batches.each_record do |record|
        record.index_page
      end
    end
  end
end
