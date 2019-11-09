class Page < ApplicationRecord
  include Redis::Objects

  belongs_to :host
  has_many :page_words
  has_many :words, through: :page_words

  validates :url_string, presence: true, uniqueness: true

  value :cached_body, marshal: true, compress: true, expireat: { Time.now + 20.minutes }
  value :cached_title, expireat: { Time.now + 20.minutes }
  set   :cached_links, expireat: { Time.now + 20.minutes }

  def uri
    @uri ||= begin
      URI(self[:url_string])
    end
  end

  def cache_page(force = false)
    unless cached_body.present? || force
      cached_body.value = mechanize_page.body
    end

    unless cached_title.present? || force
      cached_title.value = mechanize_page.title
    end

    unless cached_links.present? || force
      cached_links.clear
      cached_links.merge mechanize_page.links.map do |mechanize_link|
        mechanize_link.resolved_uri rescue nil
      end.compact
    end
  end

  def noko_doc
    return nil unless cached_body.present?
    @noko_doc ||= begin
      require 'nokogiri'
      doc = Nokogiri::HTML.parse(cached_page_body.value)
      doc.xpath("//script").remove
      doc
    end
  end

  def mechanize_page
    @mechanize_page || fetch_mechanize_page
  end

  def fetch_mechanize_page
    require 'mechanize'
    agent = Mechanize.new
    @mechanize_page = agent.get(self[:url_string])
    return nil unless @mechanize_page.is_a?(Mechanize::Page)

    @mechanize_page
  rescue Mechanize::ResponseCodeError => e
    Rails.logger.error e.message
    nil
  end
end
