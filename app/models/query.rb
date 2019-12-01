# frozen_string_literal: true

class Query < ApplicationRecord
  validates :value, presence: true

  # @return [Array<String>]
  def words_in_query
    value.split(/\s/)
  end

  def execute
    # Only query for words we've seen before
    words = Word.where(value: words_in_query)
    cached_words = words.map { |word| Cached::Word.new word }

    # Get all pages for all words
    pages = cached_words.map(&:pages).flatten.uniq
    cached_pages = pages.map { |page| Cached::Page.new page }

    hit_set = Set.new
    cached_pages.each do |cached_page|
      next if cached_page.content.blank?
      next if cached_page.content['extracted_words'].blank?

      total_words_on_page = cached_page.page[:word_count]
      total_words_on_page ||= cached_page.content['extracted_words'].count

      words.each do |word|
        page_word = cached_page.page_words.find do |pw|
          pw.word_id == word.id
        end

        hit_set << {
          url_string: cached_page.page.url_string,
          word: word.value,
          count: page_word.page_count,
          total_words_on_page: total_words_on_page
        }
      end
    end

    hit_set.to_a.sort_by { |h| h[:count].to_f / h[:total_words_on_page].to_f }.reverse
  end
end
