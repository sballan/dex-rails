# frozen_string_literal: true

class IndexPageJob < ApplicationJob
  queue_as :indexing

  discard_on Page::BadCrawl

  # @param [Page] page
  def perform(page)
    Rails.logger.info "Attempting page index for: #{page.url_string}"

    unless page.index_allowed?
      Rails.logger.error "Not indexing, index not allowed for #{page.url_string}"
      return
    end

    if page.recently_indexed?(30.seconds)
      Rails.logger.warn "Not indexing, indexed too recently: #{page.url_string}"
      return
    end

    Rails.logger.info "Attempting to download page before indexing: #{page.url_string}"
    Services::PageCrawl.persist_page_content(page)

    extracted_words_map = {}.tap do |map|
      page.content['extracted_words'].each do |extracted_word|
        map[extracted_word] ||= 0
        map[extracted_word] += 1
      end
    end

    words_strings = extracted_words_map.keys

    word_objects = Word.fetch_persisted_objects_for(words_strings)

    word_objects.map do |word|
      page_count = extracted_words_map[word[:value]]
      IndexPageWordJob.perform_later(page.id, word[:id], page_count: page_count)
    end
  end
end
