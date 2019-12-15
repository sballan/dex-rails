# frozen_string_literal: true

class Page < ApplicationRecord
  class BadCrawl < StandardError; end
  class LimitReached < StandardError; end

  belongs_to :host
  has_many :page_words, dependent: :destroy
  has_many :words, through: :page_words

  has_and_belongs_to_many :indexing_batches

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

  def fetch_with_agent(agent)
    Rails.logger.info "Attempting to fetch page: #{url_string}"

    if host.rate_limit_reached?
      self[:download_failure] = Time.now.utc
      save!
      raise Page::LimitReached, "Rate limit reached, skipping #{self[:url_string]}"
    end

    Rails.logger.info "Fetching page: #{self[:url_string]}"

    host.increment_crawls

    agent ||= Mechanize.new
    agent.robots = true
    mechanize_page = agent.get(self[:url_string])

    unless mechanize_page.is_a?(Mechanize::Page)
      raise Page::BadCrawl, 'Only html pages are supported'
    end

    mechanize_page.body.to_s
  rescue Mechanize::ResponseCodeError => e
    Rails.logger.error e.message
    self[:download_failure] = Time.now.utc
    save!
    raise Page::BadCrawl, "Couldn't reach this page"
  end

  def create_mechanize_page
    unless host.allowed?(self[:url_string])
      self[:download_invalid] = Time.now.utc
      save!
      raise Page::BadCrawl, "Host not allowed for this page: #{self[:url_string]}"
    end

    if host.rate_limit_reached?
      self[:download_failure] = Time.now.utc
      save!
      raise Page::LimitReached, "Rate limit reached, skipping #{self[:url_string]}"
    end

    Rails.logger.info "Fetching page: #{self[:url_string]}"

    host.increment_crawls

    agent = Mechanize.new
    agent.robots = true
    mechanize_page = agent.get(self[:url_string])

    unless mechanize_page.is_a?(Mechanize::Page)
      raise Page::BadCrawl, 'Only html pages are supported'
    end

    mechanize_page
  rescue Mechanize::ResponseCodeError => e
    Rails.logger.error e.message
    self[:download_failure] = Time.now.utc
    save
    raise Page::BadCrawl, "Couldn't reach this page"
  end

  def recently_indexed?(index_interval = nil)
    last_download = [
      download_success.to_i || 0,
      download_failure.to_i || 0,
      download_invalid.to_i || 0
    ].max

    index_interval ||= page.host.success_retry_seconds

    Time.now.to_i < last_download + index_interval.to_i
  end

  def index_allowed?
    return false unless host.allowed?(url_string)
    return false if host.rate_limit_reached?

    true
  end
end
