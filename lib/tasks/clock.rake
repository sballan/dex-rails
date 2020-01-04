namespace :clock do
  desc 'Run every 10 minutes'
  task ten: :environment do
    loop do
      Rails.logger.info "Clock 10min tick"
      Index::QueueFetchPagesJob.perform_later(
        ENV.fetch('PAGE_QUEUE_FETCH_SIZE', 1000).to_i
      )
      Index::QueueIndexPagesJob.perform_later(
        ENV.fetch('PAGE_QUEUE_INDEX_SIZE', 1000).to_i
      )
      sleep 10.minutes
    end
  end

  desc 'Run every 1 minute'
  task one: :environment do
    loop do
      Rails.logger.info 'Clock 1min tick'

      fetch_num = 10
      index_num = 20

      Rails.logger.info "Clock is scheduling #{fetch_num} to fetch and #{index_num} to index"
      Index::QueueFetchPagesJob.perform_later fetch_num
      Index::QueueIndexPagesJob.perform_later index_num

      sleep 1.minute
    end
  end
end