web: rails s --port $PORT --environment $RAILS_ENV
worker: sidekiq --environment $RAILS_ENV
worker_clone: sidekiq --environment $RAILS_ENV
worker_high_thread: env RAILS_MAX_THREADS=5 sidekiq --environment $RAILS_ENV
worker_low_thread: env RAILS_MAX_THREADS=2 sidekiq --environment $RAILS_ENV
