class QueueParseWordsForPagesJob < ApplicationJob
  queue_as :default

  def perform(start_index=1, end_index=10)
    (start_index..end_index).each do |index|
      ParseWordsForPageJob.perform_later(index)
    end
  end
end
