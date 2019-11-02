class Page < ApplicationRecord
  belongs_to :url

  serialize :links, JSON

  validates :links, presence: true

  def document
    require 'nokogiri'
    @document = Nokogiri::HTML.parse(body).tap do |noko_doc|
      noko_doc.xpath("//script").remove
    end
  end

  def create_urls_for_links
    links.map do |link|
      Url.find_or_create_by value: link
    end
  end

end
