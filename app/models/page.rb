class Page < ApplicationRecord
  belongs_to :url
  has_and_belongs_to_many :docs, class_name: '::Text::Doc'

  serialize :links, JSON

  def refresh
    raise "This page cannot be fetched" if mechanize_page.nil?

    self[:body] = mechanize_page.body
    self[:title] = mechanize_page.title
    self[:links] = mechanize_page.links.map do |mechanize_link|
      mechanize_link.resolved_uri rescue nil
    end.compact
    self
  end

  def refresh!
    refresh
    return self if save!
  end

  def noko_doc
    refresh! unless self[:body].present?

    require 'nokogiri'
    doc = Nokogiri::HTML.parse(self[:body])
    doc.xpath("//script").remove
    doc
  end

  def mechanize_page
    @mechanize_page || fetch_mechanize_page
  end

  def fetch_mechanize_page
    require 'mechanize'
    agent = Mechanize.new
    page = agent.get(url.value)
    return nil unless page.is_a?(Mechanize::Page)

    @mechanize_page = agent.get(url.value)
  end

end
