redis_url = ENV.fetch('REDIS_URL', 'redis://localhost')
Redis::Objects.redis = Redis.new(url: redis_url)
