# frozen_string_literal: true

module Index
  def self.table_name_prefix
    'index_'
  end

  def mechanize_agent
    return @agent unless @agent.nil?

    @agent ||= Mechanize.new
    @agent.robots = true
    @agent
  end
end
