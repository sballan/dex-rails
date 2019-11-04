module Crawling
  class DownloadUrlJob < ApplicationJob
    queue_as :downloading

    def perform(url)
      if url.is_a? Integer
        url = Url.find url
      end

      page = Page.find_or_create_by url: url
      DownloadPageJob.perform_later page.id
    end
  end
end
