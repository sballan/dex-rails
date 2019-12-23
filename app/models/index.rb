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
end
