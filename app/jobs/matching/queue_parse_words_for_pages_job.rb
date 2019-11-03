module Matching
  class QueueParseWordsForPagesJob < ApplicationJob
    queue_as :low

    def perform(start_index=1, end_index=10)
      (start_index..end_index).each do |index|
        Matching::RunFullPageParseJob.perform_later(index)
      end
    end
  end
end
