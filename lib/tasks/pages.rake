namespace :pages do
  desc 'Queue pages to be fetched'
  task queue_fetch: :environment do
    Index::QueueFetchPagesJob.perform_now(
      ENV.fetch('PAGE_QUEUE_FETCH_SIZE', 1000).to_i
    )
  end

  desc 'Queue pages to be indexed'
  task queue_index: :environment do
    Index::QueueIndexPagesJob.perform_now(
      ENV.fetch('PAGE_QUEUE_INDEX_SIZE', 1000).to_i
    )
  end
end
