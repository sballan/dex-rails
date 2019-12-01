class CreatePagesForUrlsJob < ApplicationJob
  queue_as :persisting

  rescue_from(Page::LimitReached) do
    retry_job queue: :retry_persisting, wait: Random.rand(1..60)
  end

  def perform(urls)
    urls.map do |url_string|
      page = Page.find_or_create_by url_string: url_string
      Services::PageCrawl.persist_page_content(page) if Services::PageCrawl.cache_crawl_allowed?(page)
    end

    GC.start(full_mark: false, immediate_sweep: false)
  end
end
