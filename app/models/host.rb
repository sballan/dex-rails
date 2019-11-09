class Host < ApplicationRecord
  include Redis::Objects

  has_many :pages

  validates :url_string, presence: true, uniqueness: true

  value :cached_robots_txt, compress: true, expireat: -> { Time.now + 1.hour }

  def robots_txt
    if cached_robots_txt.empty?
      cached_robots_txt.value = fetch_robots_txt
    end
    cached_robots_txt.value
  end

  def robots_txt_url
    "#{url_string}/robots.txt"
  end

  def fetch_robots_txt
    require 'mechanize'
    agent = Mechanize.new
    agent.get(robots_txt_url)
  end


end