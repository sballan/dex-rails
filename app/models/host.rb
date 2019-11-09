class Host < ApplicationRecord
  include Redis::Objects

  has_many :pages

  validates :limit_time, presence: true
  validates :host_url_string, presence: true, uniqueness: true

  value :last_crawled, marshal: true, expireat: -> { Time.now + 1.minute }

  value :crawl_started, marshal: true, expireat: -> { Time.now + 1.minute }
  counter :crawls_since_started, expireat: -> { Time.now + 1.hour }

  def increment_crawls
    crawls_since_started.increment
  end

  def rate_limit_reached?
    return false unless crawl_started.present?
    usage = crawls_since_started.value * self[:limit_time]

    (crawl_started.value + usage) > Time.now
  end

  def found?
    robotstxt_parser.found?
  end

  def allowed?(url_string)
    robotstxt_parser.allowed?(url_string)
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