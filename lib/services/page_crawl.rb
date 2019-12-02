# frozen_string_literal: true

module Services
  module PageCrawl
    module_function

    # @param [Page] page
    def crawl(page)
      unless crawl_allowed??(page)
        Rails.logger.info "Skipping crawl for #{page[:url_string]}"
        return
      end

      if page.content.blank? || page.content['extracted_words'].blank?
        CreatePagesForUrlsJob.perform_later [page.url_string]
        return
      end

      cached_page = Cached::Page.new(page)
      cached_page.page

      if cached_page.content['links'].present?
        cached_page.content['links'].each_slice(20) do |links|
          CreatePagesForUrlsJob.perform_later links
        end
      end

      extracted_words_map = create_extracted_words_map(cached_page.content['extracted_words'])

      # Get words on this page
      words_strings = extracted_words_map.keys

      # Find db words that exist
      found_words = Word.where(value: words_strings).to_a
      # Find words that don't exist yet in db
      missing_words_strings = words_strings - found_words.map(&:value)

      missing_words_objects = missing_words_strings.map { |w| { value: w } }
      created_words = missing_words_objects.map do |word_object|
        Word.create_or_find_by word_object
      end

      found_words = found_words.concat(created_words)

      page_words = found_words.map do |word|
        PageWord.create_or_find_by word: word, page: cached_page.page
      end

      page_words.each do |page_word|
        page_word[:page_count] = extracted_words_map[page_word.word.value]
        page_word.save
      end

      page.touch
    end

    def crawl_allowed?(page)
      allowed = true

      allowed = false unless page.host.allowed?(page[:url_string])
      allowed = false if page.host.rate_limit_reached?

      last_success = page[:download_success] || 0
      last_failure = page[:download_failure] || 0
      last_invalid = page[:download_invalid] || 0

      if Time.now < last_success + page.host.success_retry_seconds
        Rails.logger.info "Crawl not allowed, success too recent: #{page[:download_success]}"
        allowed = false
      else
        Rails.logger.debug "Crawl allowed, last success: #{last_success}"
      end

      if Time.now < last_failure + page.host.failure_retry_seconds
        Rails.logger.info "Crawl not allowed, failure too recent: #{page[:download_failure]}"
        allowed = false
      else
        Rails.logger.debug "Crawl allowed, last failure: #{last_failure}"
      end

      if Time.now < last_invalid + page.host.invalid_retry_seconds
        Rails.logger.info "Crawl not allowed, invalid too recent: #{page[:download_invalid]}"
        allowed = false
      else
        Rails.logger.debug "Crawl allowed, last invalid: #{last_invalid}"
      end

      allowed
    end

    def extract_words(words_to_extract)
      text = Html2Text.convert words_to_extract
      word_values = text.split /\s/
      word_values.map! do |word_value|
        word_value.downcase
      rescue StandardError => e
        Rails.logger.info "Could not downcase #{word_value}: #{e.message}"
      else
        word_value
      end
    end

    def create_extracted_words_map(extracted_words)
      {}.tap do |map|
        extracted_words.each do |extracted_word|
          map[extracted_word] ||= 0
          map[extracted_word] += 1
        end
      end
    end

    def persist_page_content(page)
      page[:content] = mechanize_page_content(page)
      page[:download_success] = Time.now.utc
      page.save!

      Rails.logger.debug "Successfully persisted #{page[:url_string]}"
      page
    end

    def mechanize_page_content(page)
      Rails.logger.debug "Fetching mechanize_page_content: #{page[:url_string]}"

      mechanize_page = create_mechanize_page(page)
      noko_doc = Nokogiri::HTML.parse(mechanize_page.body)
      noko_doc.xpath('//script').remove

      extracted_words = extract_words(noko_doc.text)

      {
        title: mechanize_page.title,
        links: mechanize_page.links.map do |mechanize_link|
          mechanize_link.resolved_uri.to_s
               rescue StandardError
                 nil
        end.compact,
        extracted_words: extracted_words
      }
    end

    def create_mechanize_page(page)
      Rails.logger.debug "Fetching mechanize_page: #{page[:url_string]}"

      if page.host.rate_limit_reached?
        page[:download_failure] = Time.now.utc
        page.save
        raise Page::LimitReached, "Rate limit reached, skipping #{page[:url_string]}"
      end

      unless page.host.found?
        page[:download_invalid] = Time.now.utc
        page.save!
        raise Page::BadCrawl, "Cannot find this host: #{page.host.host_url_string}"
      end

      unless page.host.allowed?(page[:url_string])
        page[:download_invalid] = Time.now.utc
        page.save!
        raise Page::BadCrawl, "Now allowed to crawl this page: #{page[:url_string]}"
      end

      Rails.logger.debug "\n\nFetching page: #{page[:url_string]}\n"

      agent = Mechanize.new

      page.host.increment_crawls

      @mechanize_page = agent.get(page[:url_string])

      unless @mechanize_page.is_a?(Mechanize::Page)
        raise Page::BadCrawl, 'Only html pages are supported'
      end

      @mechanize_page
    rescue Mechanize::ResponseCodeError => e
      Rails.logger.error e.message
      page[:download_failure] = Time.now.utc
      page.save
      raise Page::BadCrawl, "Couldn't reach this page"
    end
  end
end
