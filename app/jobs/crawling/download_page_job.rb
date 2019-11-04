module Crawling
  class DownloadPageJob < ApplicationJob
    queue_as :downloading

    discard_on ::Page::BadDownloadError

    def perform(page)
      if page.is_a? Integer
        page = Page.find page
      end
      page.refresh unless page.body.present?
    end
  end
end
