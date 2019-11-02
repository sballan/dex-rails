web: bundle exec rails s -b 0.0.0.0

# worker: bundle exec sidekiq
worker_critical: bundle exec sidekiq -q critical
worker_default: bundle exec sidekiq -q default -q low