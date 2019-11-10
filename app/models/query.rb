class Query < ApplicationRecord
  include Redis::Objects

  validates :value, presence: true

  hash_key :recent_queries, marshal: true, compress: true, expireat: -> { Time.now + 10.seconds }

  list :cached_hits, marshal: true, compress: true, expireat: -> { Time.now + 10.seconds }

  # @return [Array<String>]
  def words_in_query
    value.split(/\s/)
  end

  def cache_hits
    if recent_queries.has? self[:value]
      return
    end

    response = self.execute
  end


  def execute
    words = Word.where(value: words_in_query)
    pages = words.map(&:pages).flatten

    hits = []
    pages.each do |page|
      total_words_on_page = page.extract_words.count

      words_in_query.each do |word_in_query|
        hits << {
          url_string: page.url_string,
          word: word_in_query,
          count: page.cache_words_map[word_in_query].to_i,
          total_words_on_page: total_words_on_page
        }
      end
    end

    hits.sort_by {|h| h[:count].to_f / h[:total_words_on_page].to_f}.reverse
  end
end
