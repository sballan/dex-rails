web: bundle exec rails s --port $PORT --environment $RAILS_ENV
worker: bundle exec sidekiq --environment $RAILS_ENV
worker_indexing: bundle exec sidekiq --environment $RAILS_ENV -q indexing
