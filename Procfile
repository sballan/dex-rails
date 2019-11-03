web: bundle exec rails s -b 0.0.0.0

worker: bundle exec sidekiq
worker_internal: bundle exec sidekiq -q internal
worker_critical: bundle exec sidekiq -q critical
worker_default:  bundle exec sidekiq -q critical -q default
worker_low:      bundle exec sidekiq -q low