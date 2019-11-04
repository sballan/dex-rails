web: bundle exec rails s -b 0.0.0.0

worker: bundle exec sidekiq
worker_downloading:  bundle exec sidekiq -q downloading -q critical
worker_parsing:  bundle exec sidekiq -q parsing -q critical
worker_crawling:  bundle exec sidekiq -q crawling -q critical