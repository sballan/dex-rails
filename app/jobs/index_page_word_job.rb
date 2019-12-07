# frozen_string_literal: true

class IndexPageWordJob < ApplicationJob
  queue_as :indexing

  def perform(page_id, word_id, indexes)
    page_word = PageWord.create_or_find_by! page_id: page_id, word_id: word_id
    page_word[:page_count] = indexes[:page_count]
    page_word.save!
  end
end
