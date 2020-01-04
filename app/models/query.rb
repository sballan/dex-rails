# frozen_string_literal: true

class Query < ApplicationRecord
  validates :value, presence: true

  def execute
    words_in_query = value.split(/\s/).map(&:downcase)

    # Start with the first word
    first_word_value = words_in_query.shift
    first_word = Index::Word.where(value: first_word_value)
    first_word.page_words.in_batches.each_record do |record|

    end


    hit_set = Set.new
    Index::PageWord.where(index_word_id: word_ids).limit(1000).in_batches.each_record do |page_word|
      page_hit = process_page_hit(page_word)
      hit_set << page_hit if page_hit.present?
    end

    hit_set.to_a.sort_by do |hit|
      # some weird math...probably bad.
      order_rating = hit[:first_index]
      freq_rating = hit[:total_words_on_page].to_f / hit[:count]
      order_rating * freq_rating
    end
  end

  def process_page_hit(page_word)
    {
      url_string: page_word.page.url_string,
      word: page_word.word.value,
      count: page_word.data['word_count'],
      first_index: page_word.data['first_index'],
      total_words_on_page: page_word.data['total_words_on_page']
    }
  end
end
