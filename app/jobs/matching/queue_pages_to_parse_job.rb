module Matching
  class QueuePagesToParseJob < ActiveJob::Base
    queue_as :critical

    def perform(num = 1)
      pages = Page.includes(:page_fragments).where(page_fragments: { page_id: nil }).limit(num)

      pages.each do |page|
        ParsePageWordsJob.perform_later(page.id)
      end
    end
  end
end
