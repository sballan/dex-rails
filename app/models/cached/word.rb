# frozen_string_literal: true

module Cached
  class Word
    attr_reader :word

    # @param [Word]
    def initialize(word)
      @word = word
    end

    def key
      @word.cache_key
    end

    def version_key
      @word.cache_key_with_version
    end

    def pages
      return @pages if @pages.present?

      Cached.log_memory_miss(name: 'Word', message: "missed 'pages'")

      @pages = Services::Cache.fetch("#{version_key}/pages", expire_time: 1.day) do
        Cached.log_store_miss(name: 'Word', message: "missed 'pages'")
        @word.pages.to_a
      end
    end

    def page_words
      return @page_words if @page_words.present?

      Cached.log_memory_miss(name: 'Word', message: "missed 'page_words'")

      @page_words = Services::Cache.fetch("#{version_key}/page_words", expire_time: 10.minutes) do
        Cached.log_store_miss(name: 'Word', message: "missed 'page_words'")
        @word.page_words.to_a
      end
    end
  end
end
