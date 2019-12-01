# frozen_string_literal: true

class Host < ApplicationRecord
  include Redis::Objects

  has_many :pages, dependent: :destroy

  validates :limit_time, presence: true
  validates :host_url_string, presence: true, uniqueness: true

  validates :success_retry_seconds, presence: true
  validates :failure_retry_seconds, presence: true
  validates :invalid_retry_seconds, presence: true

  value :crawl_started_at, marshal: true, expireat: -> { Time.now + 1.day }
  counter :crawls_since_started, expireat: -> { Time.now + 1.day }

  set :urls_to_fetch
  set :urls_fetched

  def crawl
    crawl_started_at.value = Time.zone.now if crawl_started_at.nil?

    url_strings = pages.map(&:url_string)

    url_strings.each do |url_string|
      CrawlHostJob.perform_later url_string
    end
  end

  def increment_crawls
    crawl_started_at.value = Time.zone.now if crawl_started_at.nil?
    crawls_since_started.increment
  end

  def rate_limit_reached?
    return false if crawl_started_at.nil?
    return false if crawls_since_started.value == 0

    usage = crawls_since_started.value * self[:limit_time]

    (crawl_started_at.value + usage) > Time.now
  end

  def found?
    if robotstxt_parser.found?
      Rails.logger.debug "Host found: #{self[:host_url_string]}"
      true
    else
      false
    end
  end

  def allowed?(url_string)
    if found? && robotstxt_parser.allowed?(url_string)
      Rails.logger.debug "Url allowed: #{url_string}"
      true
    else
      false
    end
  end

  # @return [Robotstxt::Parser]
  def robotstxt_parser
    @robotstxt_parser ||= Robotstxt::Parser.new
    unless @robotstxt_parser.found?
      @robotstxt_parser.get(self[:host_url_string])
    end
    @robotstxt_parser
  end
end
