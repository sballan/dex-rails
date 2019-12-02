# frozen_string_literal: true

module Services
  module Cache
    module_function

    # @param [String] key
    def delete(_key)
      Rails.cache.delete
    end

    # @param [String] key
    #
    # @return [Boolean]
    def exist?(key)
      Rails.cache.exists?(key)
    end

    def fetch(key, expire_time: nil, skip_nil: true, &block)
      rails_cache_opts = {}
      rails_cache_opts[:expire_time] = expire_time if expire_time
      rails_cache_opts[:skip_nil] = skip_nil

      if block_given?
        Rails.cache.fetch(key, rails_cache_opts) { block.call }
      else
        raise 'Services::Cache.fetch requires block'
      end
    end

    # @param [String] key
    def read(key)
      Rails.cache.read(key)
    end

    # @param [String] key
    def write(key, value, expire_time: nil)
      rails_cache_opts = {}
      rails_cache_opts[:expire_time] = expire_time if expire_time

      Rails.cache.write(key, value, rails_cache_opts)
    end
  end
end
