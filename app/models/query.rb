class Query < ApplicationRecord
  include Redis::Objects

  validates :value, presence: true

  value :cached_response, marshal: true, compress: true, expireat: -> { Time.now + 1.minute }

  # @return [Array<String>]
  def words_in_query
    value.split(/\s/)
  end

  def response
    unless cached_response.nil?
      return cached_response.value
    end

    Rails.logger.debug "Response not cached, executing query: #{value}"

    cached_response.value = res = execute
  end


  def execute
    # Only query for words we've seen before
    words = Word.where(value: words_in_query)

    # Get all pages for all words
    pages = words.map(&:cache_db_pages).flatten.uniq

    hit_set = Set.new
    pages.each do |page|
      total_words_on_page = page[:word_count]
      total_words_on_page ||= page.cache_page_content[:extracted_words].count


      words_in_query.each do |word_in_query|
        hit_set << {
          url_string: page.url_string,
          word: word_in_query,
          count: page.extracted_words_map[word_in_query],
          total_words_on_page: total_words_on_page
        }
      end
    end

    hit_set.to_a.sort_by {|h| h[:count].to_f / h[:total_words_on_page].to_f}.reverse
  end
end
