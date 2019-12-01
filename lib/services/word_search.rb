# frozen_string_literal: true

module Services
  module WordSearch
    # @return [Array<String>]
    def extract_words_from_query(query)
      query.value.split(/\s/)
    end

    def response
      return query.cached_response.value unless query.cached_response.nil?

      Rails.logger.debug "Response not cached, executing query: #{query.value}"

      query.cached_response.value = execute(query)
    end

    def execute(query)
      words_in_query = extract_words_from_query(query)

      # Only query for words we've seen before
      words = Word.where(value: words_in_query)

      # Get all pages for all words
      pages = words.map(&:cache_db_pages).flatten.uniq

      hit_set = Set.new
      pages.each do |page|
        next if page.cache_db_content.blank?
        next if page.cache_db_content['extracted_words'].blank?

        total_words_on_page = page[:word_count]
        total_words_on_page ||= page.cache_db_content['extracted_words'].count

        words_in_query.each do |word_in_query|
          hit_set << {
            url_string: page.url_string,
            word: word_in_query,
            count: page.extracted_words_map[word_in_query],
            total_words_on_page: total_words_on_page
          }
        end
      end

      hit_set.to_a.sort_by { |h| h[:count].to_f / h[:total_words_on_page].to_f }.reverse
    end
  end
end
