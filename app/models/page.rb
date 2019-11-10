class Page < ApplicationRecord
  include Redis::Objects

  belongs_to :host
  has_many :page_words
  has_many :words, through: :page_words

  validates :url_string, presence: true, uniqueness: true

  value :cached_body, marshal: true, compress: true, expireat: -> { Time.now + 1.hour }
  value :cached_title, expireat: -> { Time.now + 1.hour }
  set   :cached_links, expireat: -> { Time.now + 1.hour }

  hash_key :cached_words_map, compress: true, expireat: -> { Time.now + 1.hour }

  def crawl_links
    pages = cache_links.map {|l| Page.find_or_create_by url_string: l}
  end

  def crawl
    words_map = cache_page[:words_map]
    words_strings = words_map.keys
    word_objects = words_strings.map {|w| {value: w} }

    words = word_objects.map do |word_object|
      Word.find_or_create_by word_object
    end

    page_words = words.map do |word|
      PageWord.find_or_create_by word: word, page: self
    end

    page_words.each do |page_word|
      page_word[:page_count] = words_map[page_word.word.value].to_i
      page_word.save
    end
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
      binding.pry
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
        Rails.logger.debug "Refreshing cached_words_map: #{self[:url_string]}"

        words_map = {}
        extracted_words = extract_words

        return nil if extracted_words.empty?

        extracted_words.each do |word|
          words_map[word] ||= 0
          words_map[word] += 1
        end

        cached_words_map.bulk_set(words_map)

        cached_words_map.to_h
      else
        cached_words_map.to_h
      end
    end
  end

  def extract_words
    @extract_words ||= begin
      Rails.logger.debug "Refreshing extract_words: #{self[:url_string]}"
      text = Html2Text.convert noko_doc.text
      text.split /\s/
    end
  end

  def mechanize_page
    @mechanize_page ||= fetch_mechanize_page
  end

  # @return [Nokogiri::HTML::Document]
  def noko_doc
    Nokogiri::HTML.parse(cache_body)
  end

  # @return [Mechanize::Page]
  def fetch_mechanize_page
    if self.host.rate_limit_reached?
      raise "Rate limit reached, skipping #{self[:url_string]}"
    end

    Rails.logger.debug "\n\nFetching page: #{self[:url_string]}\n"

    agent = Mechanize.new

    self.host.increment_crawls

    @mechanize_page = agent.get(self[:url_string])
    return nil unless @mechanize_page.is_a?(Mechanize::Page)

    @mechanize_page
  rescue Mechanize::ResponseCodeError => e
    Rails.logger.error e.message
    nil
  end
end
