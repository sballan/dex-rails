module PageJob
  class Crawl < ApplicationJob
    queue_as :crawling

    def perform(page_id)
      page = Page.find page_id

      if page.cache_crawl_allowed?
        Rails.logger.debug "PageJob::Crawl - Crawl allowed for #{page.url_string}, queueing PageJob::Download"
        Download.perform_later page_id
        return
      end

      if page.page_content_persisted?
        Rails.logger.debug "PageJob::Crawl - content persisted for  #{page.url_string}, queueing PageJob::PersistLinkPages"
        PersistLinkPages.perform_later page_id
      end

      if page.page_content_persisted?
        Rails.logger.debug "PageJob::Crawl - content persisted for #{page.url_string}, queueing PageJob::PersistRelations"
        PersistRelations.perform_later page_id
      end

    end
  end
end