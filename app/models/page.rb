class Page < ApplicationRecord
  class BadCrawl < StandardError; end
  class LimitReached < StandardError; end

  include Redis::Objects

  belongs_to :host
  has_many :page_words, dependent: :destroy
  has_many :words, through: :page_words

  serialize :links, JSON
  serialize :content, JSON
  serialize :words_map, JSON

  validates :url_string, presence: true, uniqueness: true

  before_validation do
    uri = URI(self[:url_string])
    self.host ||= Host.find_or_create_by host_url_string: "#{uri.scheme}://#{uri.host}"
  end
end
