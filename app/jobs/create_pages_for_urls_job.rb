# frozen_string_literal: true

class CreatePagesForUrlsJob < ApplicationJob
  queue_as :persisting

  rescue_from(Page::LimitReached) do
    retry_job queue: :retry_persisting, wait: Random.rand((10.minutes)..(6.hours))
  end

  def perform(urls)
    urls.map do |url_string|
      page = Page.find_or_create_by url_string: url_string
      if Services::PageCrawl.cache_crawl_allowed?(page)
        Services::PageCrawl.persist_page_content(page)
      end
    end

    GC.start(full_mark: false, immediate_sweep: false)
  end
end
