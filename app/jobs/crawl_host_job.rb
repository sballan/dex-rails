
class CrawlHostJob < ApplicationJob
  queue_as :crawling

  discard_on Page::BadCrawl

  rescue_from(Page::LimitReached) do
    retry_job queue: :retry_crawling, wait: 30.seconds
  end


  def perform(url_string)
    uri = URI(url_string)

    host = Host.find_or_create_by! host_url_string: "#{uri.scheme}://#{uri.host}"
    page = Page.find_or_create_by! url_string: url_string

    host.pages << page unless host.pages.include? page
    host.save!

    page.crawl
    GC.start(full_mark: true, immediate_sweep: false)
  end
end