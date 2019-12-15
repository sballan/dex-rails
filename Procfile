web: bundle exec rails s --port $PORT --environment $RAILS_ENV
worker: bundle exec sidekiq --environment $RAILS_ENV
worker2: bundle exec sidekiq --environment $RAILS_ENV
worker3: bundle exec sidekiq --environment $RAILS_ENV
worker_downloading: bundle exec sidekiq --environment $RAILS_ENV -q downloading
worker_indexing: bundle exec sidekiq --environment $RAILS_ENV -q indexing
