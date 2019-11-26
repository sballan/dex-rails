module PageJob
  class Download < ApplicationJob
    queue_as :downloading

    discard_on Page::BadCrawl

    rescue_from(Page::LimitReached) do
      retry_job queue: :retry_downloading, wait: Random.rand((1.minute.to_i)..(5.minutes.to_i))
    end

    def perform(page_id)
      page = Page.find(page_id)

      if page.cache_crawl_allowed?
        page.persist_page_content
      end

      if page.page_content_persisted?
        Rails.logger.info "PageJob::Download - Persisted page: #{page.url_string}"
      end
    end

  end
end