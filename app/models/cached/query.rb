# frozen_string_literal: true

module Cached
  class Query
    attr_reader :query

    # @param [::Query] query
    def initialize(query)
      @query = query
    end

    def execute
      Services::Cache.fetch("#{@query.cache_key}/execute", expire_time: 1.week) do
        @query.execute
      end
    end
  end
end
