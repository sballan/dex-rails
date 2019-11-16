web: bundle exec rails s -p $PORT -e $RAILS_ENV
worker: bundle exec sidekiq
worker_crawling: bundle exec sidekiq -q critical -q crawling -q retry_crawling
