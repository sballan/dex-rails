class Page < ApplicationRecord
  class BadCrawl < StandardError; end
  class LimitReached < StandardError; end

  include Redis::Objects

  belongs_to :host
  has_many :page_words, dependent: :destroy
  has_many :words, through: :page_words

  serialize :links, JSON
  serialize :words_map, JSON

  validates :url_string, presence: true, uniqueness: true

  value :cached_body, marshal: true, compress: true, expireat: -> { Time.now + 1.hour }
  value :cached_title, expireat: -> { Time.now + 1.hour }
  set   :cached_links, expireat: -> { Time.now + 1.hour }

  value :cached_word_count, marshal: true, expireat: -> { Time.now + 1.hour }
  hash_key :cached_words_map, compress: true, expireat: -> { Time.now + 1.hour }
  value :cached_extracted_words, marshal: true, compress: true, expireat: -> { Time.now + 1.hour }

  before_validation do
    uri = URI(self[:url_string])
    self.host ||= Host.find_or_create_by host_url_string: "#{uri.scheme}://#{uri.host}"
  end

  def crawl
    GC.start(full_mark: true, immediate_sweep: true)

    links = cache_links
    CreatePagesForUrlsJob.perform_later links

    # Get words on this page
    words_map = cache_page[:words_map]
    words_strings = words_map.keys

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
      page_word[:page_count] = words_map[page_word.word.value].to_i
      page_word.save
    end

    GC.start(full_mark: false, immediate_sweep: false)
  end

  def cache_page(force = false)
    @cache_page = nil if force

    @cache_page ||= begin
      Rails.logger.debug "Refreshing cached fields: #{self[:url_string]}"
      {
        title: cache_title,
        body: cache_body,
        links: cache_links,
        words_map: cache_words_map
      }
    end
  end

  def cache_body(force = false)
    if force
      @cache_body = nil
      cached_body.value = nil
    end

    @cache_body ||= begin
      if cached_body.nil?
        Rails.logger.debug "Refreshing cached_body: #{self[:url_string]}"
        cached_body.value = mechanize_page.body
      else
        cached_body.value
      end
    end
  end

  def cache_title
    @cache_title ||= begin
      Rails.logger.debug "Refreshing cached_title: #{self[:url_string]}"
      cached_title.value = mechanize_page.title
    end
  end

  def cache_links
    @cache_links ||= begin
      Rails.logger.debug "Refreshing cached_links: #{self[:url_string]}"
      links = mechanize_page.links.map do |mechanize_link|
        mechanize_link.resolved_uri.to_s rescue nil
      end.compact

      cached_links.clear
      cached_links.merge links
      cached_links.to_a
    end
  end

  def cache_words_map(force = false)
    @cache_words_map = nil if force

    @cache_words_map ||= begin
      if cached_words_map.empty? || force

        if self[:words_map].present? && self[:words_map].is_a?(Hash)
          Rails.logger.debug "Loading from record cached_words_map: #{self[:url_string]}"

          words_map_hash = self[:words_map]
          cached_words_map.bulk_set(words_map_hash)

          return @cache_words_map = words_map_hash
        else
          Rails.logger.debug "Refreshing cached_words_map: #{self[:url_string]}"
        end

        words_map_hash = {}
        extracted_words = extract_words

        return @cache_words_map = words_map_hash if extracted_words.empty?

        extracted_words.each do |word|
          words_map_hash[word] ||= 0
          words_map_hash[word] += 1
        end

        self[:words_map] = words_map_hash
        save

        cached_words_map.bulk_set(words_map_hash)
      end

      cached_words_map.to_h
    end
  end

  def extract_words
    @extract_words ||= begin
      unless cached_extracted_words.nil?
        return cached_extracted_words.value
      end

      text = Html2Text.convert noko_doc.text
      cached_extracted_words.value = text.split /\s/
    end
  end

  def mechanize_page
    @mechanize_page ||= fetch_mechanize_page
  end

  # @return [Nokogiri::HTML::Document]
  def noko_doc
    @noko_doc ||=  begin
      Rails.logger.debug "Parsing noko_doc: #{self[:url_string]}"
      Nokogiri::HTML.parse(cache_body)
    end
  end

  # @return [Mechanize::Page]
  def fetch_mechanize_page
    if self.host.rate_limit_reached?
      raise LimitReached.new "Rate limit reached, skipping #{self[:url_string]}"
    end

    unless self.host.found?
      raise "Cannot find this host: #{self.host.host_url_string}"
    end

    unless self.host.allowed?(self[:url_string])
      raise BadCrawl.new "Now allowed to crawl this page: #{self[:url_string]}"
    end

    Rails.logger.debug "\n\nFetching page: #{self[:url_string]}\n"

    agent = Mechanize.new

    self.host.increment_crawls

    @mechanize_page = agent.get(self[:url_string])
    raise BadCrawl.new 'Only html pages are supported' unless @mechanize_page.is_a?(Mechanize::Page)

    @mechanize_page
  rescue Mechanize::ResponseCodeError => e
    Rails.logger.error e.message
    raise LimitReached.new "Couldn't reach this page, try again later"
  end
end
