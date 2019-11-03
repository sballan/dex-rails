module Crawling
  class FollowUrlsForPageJob < ApplicationJob
    queue_as :default

    def perform(page:, depth: 1, parse_words: false)
      return if depth < 1
      depth -= 1

      if page.is_a? Integer
        page = Page.find page
      end

      page.refresh

      page.links.each do |link|
        url = Url.find_or_create_by value: link
        page = Page.find_or_create_by url: url

        self.class.perform_later(page: page.id, depth: depth)

        if page.docs.empty? && parse_words
          Matching::ParsePageWordsJob.perform_later(page.id)
        end
      end
    end
  end
end