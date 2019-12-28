web: bundle exec rails s --port $PORT --environment $RAILS_ENV
worker: env MALLOC_ARENA_MAX=2 bundle exec sidekiq --environment $RAILS_ENV
