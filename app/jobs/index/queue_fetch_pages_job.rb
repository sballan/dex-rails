# frozen_string_literal: true

module Index
  class QueueFetchPagesJob < ApplicationJob
    queue_as :downloading

    def perform(limit = 10)
      query_limit = limit * 100
      queued_hosts = Set.new

      Index.all_pages_to_fetch(query_limit).in_batches.each_record.with_index do |record, index|
        if queued_hosts.size > limit
          Rails.logger.info "Queue Fetch Pages: queued #{queued_hosts.size} out of #{index} pages, skipping the remaining #{query_limit - index}"
          break
        end

        next if queued_hosts.include?(record.index_host_id)

        Rails.logger.info("Queueing #{record.url_string} for download")
        queued_hosts << record.index_host_id
        FetchPageJob.perform_later(record)
      end
    end
  end
end
