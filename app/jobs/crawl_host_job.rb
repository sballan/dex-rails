# frozen_string_literal: true

class CrawlHostJob < ApplicationJob
  queue_as :crawling

  discard_on Page::BadCrawl

  rescue_from(Page::LimitReached) do
    retry_job queue: :retry_crawling, wait: Random.rand((1.minute)..(1.hour))
  end

  def perform(url_string)
    uri = URI(url_string)

    host = Host.find_or_create_by! host_url_string: "#{uri.scheme}://#{uri.host}"
    page = Page.find_or_create_by! url_string: url_string

    unless Services::PageCrawl.crawl_allowed?(page)
      Rails.logger.info "Not allowed to crawl this page: #{page[:url_string]}"
      return
    end

    host.pages << page unless host.pages.include? page
    host.save!

    if page.content.blank? || page.content['extracted_words'].blank?
      CreatePagesForUrlsJob.perform_later [page.url_string]
      retry_job queue: :retry_crawling, wait: Random.rand((5.minutes)..(10.minutes))
    else
      Services::PageCrawl.crawl(page)
      GC.start(full_mark: true, immediate_sweep: true)
    end
  end
end
