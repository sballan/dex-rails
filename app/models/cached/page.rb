# frozen_string_literal: true

module Cached
  class Page
    attr_reader :page

    # @param [Page] page
    def initialize(page)
      @page = page
    end

    def key
      @page.cache_key
    end

    def version_key
      @page.cache_key_with_version
    end

    def words
      return @words if @words.present?

      Cached.log_memory_miss(name: 'Page', message: "missed 'words'")

      @words = Services::Cache.fetch("#{version_key}/words", expire_time: 1.hour) do
        Cached.log_store_miss(name: 'Page', message: "missed 'words'")
        @page.words.to_a
      end
    end

    def page_words
      return @page_words if @page_words.present?

      Cached.log_memory_miss(name: 'Page', message: "missed 'page_words'")

      @page_words = Services::Cache.fetch("#{version_key}/page_words", expire_time: 1.hour) do
        Cached.log_store_miss(name: 'Page', message: "missed 'page_words'")
        @page.page_words.to_a
      end
    end

    def content
      return @content if @content.present?

      Cached.log_memory_miss(name: 'Page', message: "missed 'content'")

      @content = Services::Cache.fetch("#{version_key}/content", expire_time: 1.hour) do
        Cached.log_store_miss(name: 'Page', message: "missed 'content'")
        @page.content
      end
    end
  end
end
