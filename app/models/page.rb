class Page < ApplicationRecord
  belongs_to :url

  serialize :links, JSON

  validates :links, presence: true

  def document
    require 'nokogiri'
    Nokogiri::HTML.parse(body)
  end

  def create_urls_for_links
    links.map do |link|
      Url.create value: link
    end
  end

end
