# frozen_string_literal: true

module Index
  class QueueFetchPagesJob < ApplicationJob
    queue_as :downloading

    def perform(limit = 10)
      queued_hosts = Set.new

      Index.all_pages_to_fetch(limit).in_batches.each_record do |record|
        next if queued_hosts.include?(record.index_host_id)

        Rails.logger.info("Queueing #{record.url_string} for download")
        queued_hosts << record.index_host_id
        FetchPageJob.perform_later(record)
      end
    end
  end
end
