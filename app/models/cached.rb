# frozen_string_literal: true

module Cached
  module_function

  def log_store_miss(name:, message:)
    Rails.logger.info "Cache Store miss #{name}: #{message}"
  end

  def log_memory_miss(name:, message:)
    Rails.logger.info "Cache Memory miss #{name}: #{message}"
  end
end
