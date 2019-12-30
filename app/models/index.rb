# frozen_string_literal: true

module Index
  def self.table_name_prefix
    'index_'
  end

  def self.mechanize_agent
    return @agent unless @agent.nil?

    @agent ||= Mechanize.new
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
      .not_indexed
      .where.not(id: Index::Page.not_fetched)
      .limit(limit)
  end

  def self.word_id_cache(word_value)
    Rails.cache.fetch(
      "/index/word_id_cache/#{word_value.hash}", expires_in: 1.day
    ) do
      Index::Word.create_or_find_by!(value: word_value).id
    end
  end

  def self.page_id_cache(url_string)
    Rails.cache.fetch(
      "/index/page_id_cache/#{url_string.hash}", expires_in: 1.hour
    ) do
      Index::Page.create_or_find_by!(url_string: url_string).id
    end
  end

  # @deprecated
  def self.word_cache(word_value)
    Rails.cache.fetch(
      "/index/word_cache/#{word_value}", expires_in: 1.day
    ) do
      Index::Word.lock.find_or_create_by!(value: word_value)
    end
  end

  # @deprecated
  def self.page_cache(url_string)
    Rails.cache.fetch(
      "/index/page_cache/#{url_string}", expires_in: 1.hour
    ) do
      Index::Page.lock.find_or_create_by!(url_string: url_string)
    end
  end
end
