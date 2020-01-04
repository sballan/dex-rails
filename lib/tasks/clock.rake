namespace :clock do
  desc 'Run every 10 minutes'
  task ten: :environment do
    ClockTenJob.perform_later
  end

  desc 'Run every 1 minute'
  task one: :environment do
    loop do
      Rails.logger.info 'Clock 1min tick'

      fetch_num = 20
      index_num = 40

      Rails.logger.info "Clock is scheduling #{fetch_num} to fetch and #{index_num} to index"
      Index::QueueFetchPagesJob.perform_later fetch_num
      Index::QueueIndexPagesJob.perform_later index_num

      sleep 1.minute
    end
  end
end