class Page < ApplicationRecord
  belongs_to :url

  serialize :links, JSON

  def document
    require 'nokogiri'
    Nokogiri::HTML.parse(body)
  end
end
