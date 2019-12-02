# frozen_string_literal: true

module Cached
  class Query
    attr_reader :query

    # @param [::Query] query
    def initialize(query)
      @query = query
    end

    def execute
      # short query time so results don't quickly become stale.  Since expire time is 5 minutes now
      # queries can only be guaranteed to be up to date to the last 5 minutes
      Services::Cache.fetch("#{@query.cache_key}/execute", expire_time: 5.minutes) do
        Services::Search.execute @query
      end
    end
  end
end
