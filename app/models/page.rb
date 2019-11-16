class Page < ApplicationRecord
  class BadCrawl < StandardError; end
  class LimitReached < StandardError; end

  include Redis::Objects

  belongs_to :host
  has_many :page_words, dependent: :destroy
  has_many :words, through: :page_words

  serialize :links, JSON
  serialize :content, JSON
  serialize :words_map, JSON

  validates :url_string, presence: true, uniqueness: true

  before_validation do
    uri = URI(self[:url_string])
    self.host ||= Host.find_or_create_by host_url_string: "#{uri.scheme}://#{uri.host}"
  end

  def crawl
    GC.start(full_mark: true, immediate_sweep: true)

    unless cache_crawl_allowed?
      Rails.logger.info "Skipping crawl for #{self[:url_string]}"
      return
    end

    persist_page_content

    if cache_db_content['links'].present?
      cache_db_content['links'].each_slice(20) do |links|
        CreatePagesForUrlsJob.perform_later links
      end
    end

    # Get words on this page
    words_strings = extracted_words_map.keys

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
      PageWord.find_or_create_by word: word, page: self
    end

    page_words.each do |page_word|
      page_word[:page_count] = extracted_words_map[page_word.word.value]
      page_word.save
    end

    GC.start(full_mark: false, immediate_sweep: false)
  end

  def cache_crawl_allowed?
    Rails.cache.fetch("#{cache_key_with_version}/crawl_allowed?") do
      crawl_allowed?
    end
  end

  def crawl_allowed?
    allowed = true

    allowed = false unless self.host.allowed?(self[:url_string])
    allowed = false if self.host.rate_limit_reached?

    last_success = self[:download_success] || 0
    last_failure = self[:download_failure] || 0
    last_invalid = self[:download_invalid] || 0

    if Time.now < last_success + host.success_retry_seconds
      Rails.logger.info "Crawl not allowed, success too recent: #{self[:url_string]}"
      allowed = false
    end

    if Time.now < last_failure + host.failure_retry_seconds
      Rails.logger.info "Crawl not allowed, failure too recent: #{self[:url_string]}"
      allowed = false
    end


    if Time.now < last_invalid + host.invalid_retry_seconds
      Rails.logger.info "Crawl not allowed, invalid too recent: #{self[:url_string]}"
      allowed = false
    end

    allowed
  end

  def extracted_words_map
    @extracted_words_map ||= begin
      {}.tap do |map|
        cache_db_content['extracted_words'].each do |extracted_word|
          map[extracted_word] ||= 0
          map[extracted_word] += 1
        end
      end
    end
  end

  def cache_db_words
    Rails.cache.fetch("#{cache_key_with_version}/db_words") do
      Rails.logger.debug "Cache miss db_words: #{self[:url_string]}"
      self.words.to_a
    end
  end

  def cache_db_page_words
    Rails.cache.fetch("#{cache_key_with_version}/db_page_words") do
      Rails.logger.debug "Cache miss db_page_words: #{self[:url_string]}"
      self.page_words.to_a
    end
  end

  def cache_db_content
    Rails.cache.fetch("#{cache_key_with_version}/db_page_content") do
      Rails.logger.debug "Cache miss page_content: #{self[:url_string]}"
      self.content
    end
  end

  def persist_page_content
    self[:content] = mechanize_page_content
    self[:download_success] = Time.now.utc
    save!

    Rails.logger.debug "Successfully persisted #{self[:url_string]}"
    self
  end

  def mechanize_page_content
    @mechanize_page_content ||= begin
      Rails.logger.debug "Fetching mechanize_page_content: #{self[:url_string]}"

      noko_doc =  Nokogiri::HTML.parse(mechanize_page.body)
      noko_doc.xpath("//script").remove

      extracted_word = extract_words(noko_doc.text)

      {
        title: mechanize_page.title,
        body: mechanize_page.body.force_encoding('ISO-8859-1'),
        links: (mechanize_page.links.map do |mechanize_link|
          mechanize_link.resolved_uri.to_s rescue nil
        end.compact),
        extracted_words: extracted_word
      }
    end
  end

  def extract_words(words_to_extract)
    Rails.logger.debug "Parsing extracted_words: #{self[:url_string]}"
    text = Html2Text.convert words_to_extract
    text.split /\s/
  end

  def mechanize_page
    @mechanize_page ||= begin
      Rails.logger.debug "Fetching mechanize_page: #{self[:url_string]}"

      if self.host.rate_limit_reached?
        self[:download_failure] = Time.now.utc
        save
        raise LimitReached.new "Rate limit reached, skipping #{self[:url_string]}"
      end

      unless self.host.found?
        self[:download_invalid] = Time.now.utc
        save
        raise BadCrawl.new "Cannot find this host: #{self.host.host_url_string}"
      end

      unless self.host.allowed?(self[:url_string])
        self[:download_invalid] = Time.now.utc
        save
        raise BadCrawl.new "Now allowed to crawl this page: #{self[:url_string]}"
      end

      Rails.logger.debug "\n\nFetching page: #{self[:url_string]}\n"

      agent = Mechanize.new

      self.host.increment_crawls

      @mechanize_page = agent.get(self[:url_string])
      self[:download_invalid] = Time.now.utc
      save
      raise BadCrawl.new 'Only html pages are supported' unless @mechanize_page.is_a?(Mechanize::Page)

      @mechanize_page
    end

  rescue Mechanize::ResponseCodeError => e
    Rails.logger.error e.message
    save
    raise BadCrawl.new "Couldn't reach this page"
  end

end
