# frozen_string_literal: true

class Word < ApplicationRecord
  include Redis::Objects

  has_many :page_words, dependent: :destroy
  has_many :pages, through: :page_words

  validates :value, presence: true

  def self.fetch_persisted_objects_for(words_strings)
    Rails.logger.info "Plucking #{words_strings.size} words"

    found_word_objects = Word.where(value: words_strings)
                             .pluck(:id, :value)
                             .map { |v| { id: v[0], value: v[1] } }

    found_word_strings = found_word_objects.map { |w| w[:value] }
    missing_words_strings = words_strings - found_word_strings
    missing_words_objects = missing_words_strings.map { |w| { value: w } }

    created_word_objects = missing_words_objects.map do |word_object|
      word = Word.create_or_find_by! word_object
      { id: word.id, value: word.value }
    end

    found_word_objects + created_word_objects
  end
end
