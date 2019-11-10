web: bundle exec rails s -p $PORT -e $RAILS_ENV
web_single: QUEUE_ADAPTER=async bundle exec rails s -p $PORT -e $RAILS_ENV

worker: bundle exec sidekiq
