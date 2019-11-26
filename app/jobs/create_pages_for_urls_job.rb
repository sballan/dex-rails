class CreatePagesForUrlsJob < ApplicationJob
  queue_as :persisting

  rescue_from(Page::LimitReached) do
    retry_job queue: :retry_persisting, wait: Random.rand(1..60)
  end

  def perform(urls)
    urls.map do |url_string|
      # create_or_find_by _should_ work better here, since have a uniq index on url_string
      page = Page.create_or_find_by url_string: url_string
      page.persist_page_content if page.cache_crawl_allowed?
    end

    GC.start(full_mark: false, immediate_sweep: false)
  end
end
