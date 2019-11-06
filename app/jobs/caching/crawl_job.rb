module Caching
  class CrawlJob < ApplicationJob
    queue_as :crawling

    def perform(url_string, depth = 1)
      return if depth < 1
      require 'mechanize'
      cached_pages = Redis::Set.new('cached_pages')
      return if cached_pages.member? url_string

      agent = Mechanize.new
      redis_page = Redis::HashKey.new(
        url_string,
        expireat: -> { Time.now + 20.minutes },
        marshal: true
      )

      begin
        mechanize_page = agent.get(url_string)
      rescue Mechanize::ResponseCodeError => e
        Rails.logger.error e.message
        nil
      end

      return nil unless mechanize_page.is_a?(Mechanize::Page)

      redis_page[:title] = mechanize_page.title
      redis_page[:body] = mechanize_page.body
      redis_page[:links] = links_to_crawl = mechanize_page.links.map do |mechanize_link|
        mechanize_link.resolved_uri.to_s rescue nil
      end.compact

      cached_pages << url_string
      Rails.logger.info "Cached #{url_string}"

      depth -= 1
      return if depth < 1
      links_to_crawl.each do |link|
        self.class.perform_later link, depth
      end
    end
  end
end