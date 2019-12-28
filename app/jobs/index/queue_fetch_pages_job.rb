# frozen_string_literal: true

module Index
  class QueueFetchPagesJob < ApplicationJob
    queue_as :indexing

    def perform(limit = 10)
      Index.all_pages_to_fetch(limit).in_batches.each_record do |record|
        FetchPageJob.perform_later(record)
      end
    end
  end
end
