module Crawling
  class FollowUrlsForUrlJob < ApplicationJob
    queue_as :default

    def perform(url:, depth: 1, parse_words: false)
      return if depth < 1
      depth -= 1

      if url.is_a? Integer
        url = Url.find url
      end

      page = Page.find_or_create_by url: url

      page.refresh

      if page.docs.empty? && parse_words
        Matching::ParsePageWordsJob.perform_later(page.id)
      end

      page.links.each do |link|
        url = Url.find_or_create_by value: link
        self.class.perform_later(url: url.id, depth: depth) unless depth < 1
      end
    end
  end
end