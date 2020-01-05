# frozen_string_literal: true

module Index
  class QueueIndexPagesJob < ApplicationJob
    queue_as :indexing

    def perform(limit = 10)
      Index.all_pages_to_index
           .order('RANDOM()')
           .limit(limit)
           .in_batches
           .each_record do |record|
        IndexPageJob.perform_later(record)
      end
    end
  end
end
