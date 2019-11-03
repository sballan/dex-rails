module Crawling
  class QueueEmptyUrlsJob < ApplicationJob
    queue_as :low

    def perform(num = 10)
      empty_urls = Url.includes(:pages).where(pages: { url_id: nil }).limit(num)
      empty_urls.each do |empty_url|
        page = Page.create(url: empty_url)
        DownloadPageJob.perform_later page.id
      end
    end
  end
end