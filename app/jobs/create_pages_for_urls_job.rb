class CreatePagesForUrlsJob < ApplicationJob
  queue_as :persisting

  rescue_from(Page::LimitReached) do
    retry_job queue: :retry_persisting, wait: Random.rand(1..60)
  end

  def perform(urls)
    urls.map do |url_string|
      page = Page.find_or_create_by url_string: url_string
      page.persist_page_content if page.cache_crawl_allowed?
    end

    GC.start(full_mark: false, immediate_sweep: false)
  end
end
