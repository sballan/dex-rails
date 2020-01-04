namespace :clock do
  desc 'Run every 10 minutes'
  task ten: :environment do
    ClockTenJob.perform_later
  end

  desc 'Run every 1 minute'
  task one: :environment do
    loop do
      Rails.logger.info 'Clock 1min tick'

      fetch_num = ENV.fetch('PAGE_QUEUE_FETCH_SIZE', 25).to_i
      index_num = ENV.fetch('PAGE_QUEUE_INDEX_SIZE', 50).to_i

      Rails.logger.info "Clock is scheduling #{fetch_num} to fetch and #{index_num} to index"
      Index::QueueFetchPagesJob.perform_later fetch_num
      Index::QueueIndexPagesJob.perform_later index_num

      sleep 1.minute
    end
  end
end