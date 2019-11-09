class Page < ApplicationRecord
  include Redis::Objects

  belongs_to :host
  has_many :page_words
  has_many :words, through: :page_words

  validates :url_string, presence: true, uniqueness: true

  value :cached_body, marshal: true, compress: true, expireat: -> { Time.now + 20.minutes }
  value :cached_title, expireat: -> { Time.now + 20.minutes }
  set   :cached_links, expireat: -> { Time.now + 20.minutes }

  def cache_page(force = false)
    if self.host.rate_limit_reached?
      Rails.logger.debug "Rate limit reached, skipping #{self[:url_string]}"
      return false
    end

    if cached_body.nil? || force
      cached_body.value = mechanize_page.body

      cached_title.value = mechanize_page.title

      links = mechanize_page.links.map do |mechanize_link|
        mechanize_link.resolved_uri.to_s rescue nil
      end.compact

      cached_links.clear
      cached_links.merge links

      return true
    end
  end

  def mechanize_page
    @mechanize_page || fetch_mechanize_page
  end

  # @return [Nokogiri::HTML::Document]
  def noko_doc
    return nil unless cached_body.present?
    @noko_doc ||= begin
      require 'nokogiri'
      doc = Nokogiri::HTML.parse(cached_body.value)
      doc.xpath("//script").remove
      doc
    end
  end

  # @return [Mechanize::Page]
  def fetch_mechanize_page
    require 'mechanize'
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
