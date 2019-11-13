class PageWord < ApplicationRecord
  include Redis::Objects

  belongs_to :page, touch: true
  belongs_to :word, touch: true # word caches page_words, so we need to touch it to invalidate its cache

  validates :page_count, presence: true

  def cache_db_page_word_count
    Rails.cache.fetch("#{cache_key_with_version}/page_word_count") do
      Rails.logger.debug "Cache miss page_word_count: #{self[:url_string]}"
      self.page[:word_count]
    end
  end
end
