module Cached
  class Page

    attr_reader :page

    # @param [::Page]
    def initialize(page)
      @page = page
    end

    def words
      @words ||= begin
        Services::Cache.fetch("#{@page.cache_key_with_version}/words") do
          Rails.logger.debug "Cache miss page.words: #{@page[:url_string]}"
          page.words.to_a
        end
      end
    end

    def page_words
      @page_words ||= begin
        Services::Cache.fetch("#{@page.cache_key_with_version}/page_words") do
          Rails.logger.debug "Cache miss page.page_words: #{@page[:url_string]}"
          @page.page_words.to_a
        end
      end
    end

    def content
      @content ||= begin
        Services::Cache.fetch("#{@page.cache_key_with_version}/content") do
          Rails.logger.debug "Cache miss page_content: #{@page[:url_string]}"
          @page.content
        end
      end
    end
  end
end