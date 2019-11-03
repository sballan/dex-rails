module Matching
  class QueuePagesToParseJob < ActiveJob::Base
    queue_as :low

    def perform(num = 1)
      pages = Page.includes(:page_fragments).where(page_fragments: { page_id: nil }).limit(1)

      pages.each do |page|
        ParsePageWordsJob.perform_now(page.id)
      end
    end
  end
end
