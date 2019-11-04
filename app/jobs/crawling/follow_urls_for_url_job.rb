module Crawling
  class FollowUrlsForUrlJob < ApplicationJob
    queue_as :crawling

    discard_on ::Page::BadDownloadError

    def perform(url:, depth: 1, parse_words: false)
      return if depth < 1
      depth -= 1

      if url.is_a? Integer
        url = Url.find url
      end

      page = Page.find_or_create_by url: url
      page.refresh unless page.links.present?

      Matching::ParsePageWordsJob.perform_later(page.id) if parse_words

      return if depth < 1

      page.links.each do |link|
        url = Url.find_by value: link
        next if url.present?

        url = Url.create value: link

        if depth == 1
          DownloadUrlJob.perform_later(url.id)
        else
          self.class.perform_later(url: url.id, depth: depth, parse_words: parse_words)
        end
      end
    end
  end
end