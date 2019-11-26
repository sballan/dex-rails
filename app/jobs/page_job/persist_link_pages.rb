module PageJob
  class PersistLinkPages < ApplicationJob
    queue_as :persisting

    def perform(page_id)
      page = Page.find(page_id)

      unless page.page_content_persisted?
        Rails.logger.info "PageJob::PersistRelations - Skipping, page not persisted #{page.url_string}"
        return
      end

      page.links.each do |link|
        Page.create_or_find_by! url_string: link
      end

      Rails.logger.info "PageJob::PersistLinkPages - link Pages persisted for: #{page.url_string}"
    end
  end
end