REDIS_CONFIG = YAML.load(ERB.new(File.new(File.expand_path('../../redis.yml', __FILE__)).read).result)[Rails.env]

REDIS_CACHE = Redis.new(:host => REDIS_CONFIG['host'], :port => REDIS_CONFIG['port'], :db => 1)
RATE_LIMIT = REDIS_CONFIG['limit']
