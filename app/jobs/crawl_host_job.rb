
class CrawlHostJob < ApplicationJob
  queue_as :crawling

  def perform(url_string)
    uri = URI(url_string)
    host = Host.find_or_create_by host_url_string: uri.host
    page = host.pages.create url_string: url_string

    page.crawl




  end
end