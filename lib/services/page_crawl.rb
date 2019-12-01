module Services
  module PageCrawl

    extend self

    # @param [Page] page
    def crawl(page)
      unless cache_crawl_allowed?(page)
        Rails.logger.info "Skipping crawl for #{page[:url_string]}"
        return
      end

      persist_page_content(page)

      if cache_db_content(page)['links'].present?
        cache_db_content(page)['links'].each_slice(20) do |links|
          CreatePagesForUrlsJob.perform_later page.links
        end
      end

      # Get words on this page
      words_strings = extracted_words_map(page).keys

      # Find db words that exist
      found_words = Word.where(value: words_strings).to_a
      # Find words that don't exist yet in db
      missing_words_strings = words_strings - found_words.map(&:value)


      missing_words_objects = missing_words_strings.map {|w| {value: w} }
      created_words = missing_words_objects.map do |word_object|
        Word.find_or_create_by word_object
      end

      found_words = found_words.concat(created_words)

      page_words = found_words.map do |word|
        PageWord.find_or_create_by word: word, page: page
      end

      page_words.each do |page_word|
        page_word[:page_count] = extracted_words_map(page)[page_word.word.value]
        page_word.save
      end
    end

    def cache_crawl_allowed?(page)
      Rails.cache.fetch("#{page.cache_key_with_version}/crawl_allowed?") do
        crawl_allowed?(page)
      end
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

    def extracted_words_map(page)
      {}.tap do |map|
        cache_db_content(page)['extracted_words'].each do |extracted_word|
          map[extracted_word] ||= 0
          map[extracted_word] += 1
        end
      end
    end

    def cache_db_words(page)
      Rails.cache.fetch("#{page.cache_key_with_version}/db_words") do
        Rails.logger.debug "Cache miss db_words: #{page[:url_string]}"
        page.words.to_a
      end
    end

    def cache_db_page_words(page)
      Rails.cache.fetch("#{page.cache_key_with_version}/db_page_words") do
        Rails.logger.debug "Cache miss db_page_words: #{page[:url_string]}"
        page.page_words.to_a
      end
    end

    def cache_db_content(page)
      Rails.cache.fetch("#{page.cache_key_with_version}/db_page_content") do
        Rails.logger.debug "Cache miss page_content: #{page[:url_string]}"
        page.content
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
      noko_doc =  Nokogiri::HTML.parse(mechanize_page.body)
      noko_doc.xpath("//script").remove

      extracted_words = extract_words(noko_doc.text)

      {
        title: mechanize_page.title,
        body: mechanize_page.body.force_encoding('ISO-8859-1'),
        links: (mechanize_page.links.map do |mechanize_link|
          mechanize_link.resolved_uri.to_s rescue nil
        end.compact),
        extracted_words: extracted_words
      }
    end

    def extract_words(words_to_extract)
      text = Html2Text.convert words_to_extract
      text.split /\s/
    end

    def create_mechanize_page(page)
      Rails.logger.debug "Fetching mechanize_page: #{page[:url_string]}"

      if page.host.rate_limit_reached?
        page[:download_failure] = Time.now.utc
        page.save
        raise Page::LimitReached.new "Rate limit reached, skipping #{page[:url_string]}"
      end

      unless page.host.found?
        page[:download_invalid] = Time.now.utc
        page.save
        raise Page::BadCrawl.new "Cannot find this host: #{page.host.host_url_string}"
      end

      unless page.host.allowed?(page[:url_string])
        page[:download_invalid] = Time.now.utc
        page.save
        raise Page::BadCrawl.new "Now allowed to crawl this page: #{page[:url_string]}"
      end

      Rails.logger.debug "\n\nFetching page: #{page[:url_string]}\n"

      agent = Mechanize.new

      page.host.increment_crawls

      @mechanize_page = agent.get(page[:url_string])
      page[:download_invalid] = Time.now.utc
      page.save
      raise Page::BadCrawl.new 'Only html pages are supported' unless @mechanize_page.is_a?(Mechanize::Page)

      @mechanize_page

    rescue Mechanize::ResponseCodeError => e
      Rails.logger.error e.message
      page[:download_failure] = Time.now.utc
      page.save
      raise Page::BadCrawl.new "Couldn't reach this page"
    end
  end
end
