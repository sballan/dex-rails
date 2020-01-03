namespace :pages do
  desc 'Queue pages to be fetched'
  task queue_fetch: :environment do
    Index::QueueFetchPagesJob.perform_now 1000
  end

  desc 'Queue pages to be indexed'
  task queue_index: :environment do
    Index::QueueIndexPagesJob.perform_now 1000
  end
end
