# frozen_string_literal: true

module Services
  module Search
    module_function

    def execute(query)
      words_in_query = query.value.split(/\s/)

      # Only query for words we've seen before
      words = Word.where(value: words_in_query)

      hit_set = Set.new
      words.each do |word|
        word.page_words.in_batches.each_record do |page_word|
          page_hit = process_page_hit(page_word)
          hit_set << page_hit unless page_hit.blank?
        end
      end

      hit_set.to_a.sort_by { |h| h[:count].to_f / h[:total_words_on_page].to_f }.reverse
    end

    def process_page_hit(page_word)
      total_words_on_page = page_word.page[:word_count]
      return if total_words_on_page.blank?

      {
        url_string: page_word.page.url_string,
        word: page_word.word.value,
        count: page_word.page_count,
        total_words_on_page: total_words_on_page
      }
    end
  end
end
