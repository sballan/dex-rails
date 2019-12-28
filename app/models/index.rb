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

  def self.all_pages_to_download(limit = nil)
    Index::Page
      .not_downloaded
      .limit(limit)
  end

  def self.all_pages_to_index(limit = nil)
    Index::Page
      .not_indexed
      .where.not(id: Index::Page.not_downloaded)
      .limit(limit)
  end

  def self.word_cache(word_value)
    Rails.cache.fetch("/index/word_cache/#{word_value}") do
      Index::Word.lock.find_or_create_by!(value: word_value)
    end
  end
end
