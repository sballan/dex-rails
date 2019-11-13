class Page < ApplicationRecord
  class BadCrawl < StandardError; end
  class LimitReached < StandardError; end

  include Redis::Objects

  belongs_to :host
  has_many :page_words, touch: true, dependent: :destroy
  has_many :words, through: :page_words

  serialize :links, JSON
  serialize :words_map, JSON

  validates :url_string, presence: true, uniqueness: true

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

  def cache_db_words
    Rails.cache.fetch("#{cache_key_with_version}/db_words") do
      Rails.logger.debug "Cache miss db_words: #{self[:url_string]}"
      self.words
    end
  end

  def cache_db_page_words
    Rails.cache.fetch("#{cache_key_with_version}/db_page_words") do
      Rails.logger.debug "Cache miss db_page_words: #{self[:url_string]}"
      self.page_words
    end
  end


  def cache_mechanize_page
    Rails.cache.fetch("#{cache_key_with_version}/mechanize_page") do
      Rails.logger.debug "Cache miss mechanize_page: #{self[:url_string]}"

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

    @extract_words ||= begin
      unless cached_extracted_words.nil?
        return cached_extracted_words.value
      end

      text = Html2Text.convert noko_doc.text
      cached_extracted_words.value = text.split /\s/
    end
  end

  def cache_extracted_words
    Rails.cache.fetch("#{cache_key_with_version}/extracted_words") do
      Rails.logger.debug "Cache miss extracted_words: #{self[:url_string]}"
      text = Html2Text.convert noko_doc.text
      text.split /\s/
    end
  end

  # @return [Nokogiri::HTML::Document]
  def cache_noko_doc
    Rails.cache.fetch("#{cache_key_with_version}/noko_doc") do
      Rails.logger.debug "Cache miss noko_doc: #{self[:url_string]}"
      Nokogiri::HTML.parse(cache_mechanize_page.body)
    end
  end
end
