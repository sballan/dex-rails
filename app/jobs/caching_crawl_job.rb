class CachingCrawlJob < ApplicationJob
  class WordsNotCachedError < StandardError; end

  queue_as :caching

  rescue_from(WordsNotCachedError) do
    retry_job queue: :persisting, wait: 1.minute
  end

  def perform(url_string)
    @pg_pages_url_string_to_id = Redis::HashKey.new 'pg_pages_url_string_to_id', marshal: true, expireat: ->{ Time.now + 1.hour }
    @pg_pages_id_to_url_string = Redis::HashKey.new 'pg_pages_id_to_url_string', marshal: true, expireat: ->{ Time.now + 1.hour }
    @pg_pages_id_to_body       = Redis::HashKey.new 'pg_pages_id_to_body',       marshal: true, expireat: ->{ Time.now + 10.minutes }

    @pg_words_id_to_value = Redis::HashKey.new 'pg_words_id_to_value', marshal: true, expireat: ->{ Time.now + 1.hour }
    @pg_words_value_to_id = Redis::HashKey.new 'pg_words_value_to_id', marshal: true, expireat: ->{ Time.now + 1.hour }

    # Only write we do
    pg_page = Page.find_or_create_by url_string: url_string
    @pg_pages_id_to_url_string[pg_page.id] = url_string
    @pg_pages_url_string_to_id[url_string] = pg_page.id

    # Download and cache page if not cached yet
    if @pg_pages_id_to_body[pg_page.id].nil?
      page_body = @pg_pages_id_to_body[pg_page.id] = pg_page.mechanize_page.body
    else
      page_body = @pg_pages_id_to_body[pg_page.id]
    end

    # Extract word strings from page body
    nokogiri_doc = Nokogiri::HTML.parse(page_body)
    word_strings = Html2Text.convert(nokogiri_doc.text).split /\s/

    # Find uncached words, make sure they exist in the database, and cache them
    cached_words = {}
    uncached_word_strings = []

    word_strings.each do |word_string|
      word_id = @pg_words_value_to_id[word_string]

      if word_id.nil?
        uncached_word_strings << word_string
      else
        cached_words[word_id] = {
          value: word_string
        }
      end
    end

    if uncached_word_strings.any?
      CreateWordsForValuesJob.perform_later uncached_word_strings
      raise WordsNotCachedError
    end
  end
end