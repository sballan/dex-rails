class Page < ApplicationRecord
  belongs_to :url
  has_and_belongs_to_many :text_docs

  validates :title, presence: true
  validates :body, presence: true
  validates :links, presence: true

  serialize :links, JSON

  def create_urls_for_links
    self[:links].map do |link|
      Url.find_or_create_by value: link
    end
  end

  def refresh
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
    @mechanize_page = agent.get(url.value)
  end

end
