module Crawling
  class DownloadPageJob < ApplicationJob
    queue_as :default

    def perform(page)
      if page.is_a? Integer
        page = Page.find Page
      end
      page.refresh!
    end
  end
end
