namespace :clock do
  desc 'Run every 10 minutes'
  task ten: :environment do
    loop do
      Rails.info "Clock tick"
      Index::QueueFetchPagesJob.perform_later(
        ENV.fetch('PAGE_QUEUE_FETCH_SIZE', 1000).to_i
      )
      Index::QueueIndexPagesJob.perform_later(
        ENV.fetch('PAGE_QUEUE_INDEX_SIZE', 1000).to_i
      )
      sleep 10.minutes
    end
  end
end