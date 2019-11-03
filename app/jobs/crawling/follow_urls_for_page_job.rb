module Crawling
  class FollowUrlsForPageJob < ApplicationJob
    queue_as :low

    def perform(page:, depth: 1, parse_words: false)
      return if depth < 1
      depth -= 1

      if page.is_a? Integer
        page = Page.find page
      end

      page.refresh!

      link_pages = page.links.map do |link|
        url = Url.find_or_create_by value: link
        url.pages.create
      end

      link_pages.map do |page|
        self.class.perform_later(page: page.id, depth: depth)
        Matching::ParsePageWordsJob.perform_later(page.id) if parse_words
      end
    end
  end
end