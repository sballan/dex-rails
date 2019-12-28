# frozen_string_literal: true

module Services
  module Search
    module_function

    def execute(query)
      words_in_query = query.value.split(/\s/).map(&:downcase)

      # Only query for words we've seen before
      word_ids = Index::Word.where(value: words_in_query).pluck(:id)

      hit_set = Set.new
      Index::PageWord.where(index_word_id: word_ids).limit(1000).in_batches.each_record do |page_word|
        page_hit = process_page_hit(page_word)
        hit_set << page_hit if page_hit.present?
      end

      hit_set.to_a.sort_by do |hit|
        # some weird math...probably bad.
        order_rating = hit[:first_index]
        freq_rating = hit[:total_words_on_page].to_f / hit[:count].to_f
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
end
