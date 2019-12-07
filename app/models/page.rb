# frozen_string_literal: true

class Page < ApplicationRecord
  class BadCrawl < StandardError; end
  class LimitReached < StandardError; end

  belongs_to :host
  has_many :page_words, dependent: :destroy
  has_many :words, through: :page_words

  serialize :links, JSON
  serialize :content, JSON
  serialize :words_map, JSON

  validates :url_string, presence: true

  before_validation do
    unless host.present?
      uri = URI(self[:url_string])
      host_url_string = "#{uri.scheme}://#{uri.host}"
      self.host ||= Host.find_or_create_by host_url_string: host_url_string
    end
  end

  def recently_indexed?(index_interval = nil)
    last_download = [
      download_success.to_i || 0,
      download_failure.to_i || 0,
      download_invalid.to_i || 0
    ].max

    index__interval ||= page.host.success_retry_seconds
    return false if Time.now < last_download + index__interval

    true
  end

  def index_allowed?
    return false unless host.allowed?(url_string)
    return false unless host.rate_limit_reached?
  end
end
