# frozen_string_literal: true

module Services
  module Search
    module_function

    def execute(query)
      words_in_query = query.value.split(/\s/)

      # Only query for words we've seen before
      words = Word.where(value: words_in_query)
      cached_words = words.map { |word| Cached::Word.new word }

      # Get all pages for all words
      pages = cached_words.map(&:pages).flatten.uniq
      cached_pages = pages.map { |page| Cached::Page.new page }

      hit_set = Set.new
      cached_pages.each do |cached_page|
        page_hits = process_page_hits(cached_page, words)
        page_hits.each { |hit| hit_set << hit } unless page_hits.blank?
      end

      hit_set.to_a.sort_by { |h| h[:count].to_f / h[:total_words_on_page].to_f }.reverse
    end

    def process_page_hits(cached_page, words)
      return if cached_page.content.blank?
      return if cached_page.content['extracted_words'].blank?

      total_words_on_page = cached_page.page[:word_count]
      total_words_on_page ||= cached_page.content['extracted_words'].count

      words.map do |word|
        page_word = cached_page.page_words.find do |pw|
          pw.word_id == word.id
        end

        if page_word.nil?
          nil
        else
          {
            url_string: cached_page.page.url_string,
            word: word.value,
            count: page_word.page_count,
            total_words_on_page: total_words_on_page
          }
        end
      end.compact
    end
  end
end
