# frozen_string_literal: true

class ClockTenJob < ApplicationJob
  queue_as :clock

  def perform
    10.times do
      tick
    end
  end

  def tick
    Rails.logger.info "ClockTenJob tick: #{Time.now.localtime}"

    Index::QueueFetchPagesJob.perform_later(
      ENV.fetch('PAGE_QUEUE_FETCH_SIZE', 50).to_i
    )
    Index::QueueIndexPagesJob.perform_later(
      ENV.fetch('PAGE_QUEUE_INDEX_SIZE', 100).to_i
    )
    sleep 1.minute
  end
end



