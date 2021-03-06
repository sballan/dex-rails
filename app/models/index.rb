# frozen_string_literal: true

require 'digest/sha1'

module Index
  def self.table_name_prefix
    'index_'
  end

  def self.mechanize_agent
    return @agent unless @agent.nil?

    @agent ||= Mechanize.new
    @agent.history.max_size = 10 # default is 50
    @agent.robots = true
    @agent
  end

  def self.fetch_page(url_string)
    mechanize_agent.get(url_string)
  end

  def self.all_pages_to_fetch(limit = nil)
    Index::Page
      .not_fetched
      .limit(limit)
  end

  def self.all_pages_to_index(limit = nil)
    Index::Page
      .to_index
      .limit(limit)
  end

  def self.word_id_cache(word_value)
    key = Digest::SHA1.hexdigest(word_value)
    Rails.cache.fetch(
      "/index/word_id_cache/#{key}", expires_in: 1.month
    ) do
      Rails.logger.info "word_id_cache: Cache miss for '#{word_value}'"
      Index::Word.create_or_find_by!(value: word_value).id
    end
  end

  def self.page_id_cache(url_string)
    key = Digest::SHA1.hexdigest(url_string)
    Rails.cache.fetch(
      "/index/page_id_cache/#{key}", expires_in: 1.day
    ) do
      Rails.logger.info "page_id_cache: Cache miss for '#{url_string}'"
      Index::Page.create_or_find_by!(url_string: url_string).id
    end
  end

end
