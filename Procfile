web: bundle exec rails s --port $PORT --environment $RAILS_ENV
worker: env MALLOC_ARENA_MAX=2 bundle exec sidekiq --environment $RAILS_ENV
worker_2: bundle exec sidekiq --environment $RAILS_ENV
worker_3: bundle exec sidekiq --environment $RAILS_ENV
worker_4: bundle exec sidekiq --environment $RAILS_ENV
worker_5: bundle exec sidekiq --environment $RAILS_ENV
worker_create_pages: bundle exec sidekiq --environment $RAILS_ENV -q create_pages
worker_downloading: bundle exec sidekiq --environment $RAILS_ENV -q downloading
worker_indexing: bundle exec sidekiq --environment $RAILS_ENV -q indexing
