REDIS_CONFIG = YAML.load(ERB.new(File.new(File.expand_path('../../redis.yml', __FILE__)).read).result)[Rails.env]

REDIS_CACHE = if Rails.env.test?
                MockRedis.new
              else
                Redis.new(:host => REDIS_CONFIG['host'], :port => REDIS_CONFIG['port'], :db => 1)
              end
RATE_LIMIT = REDIS_CONFIG['limit']

GROUP_ALL_RESPONSE = "GROUP_ALL"
GROUP_RESPONSE = "G"
GROUP_NSS_RESPONSE = "UG"
GROUP_UID_RESPONSE = "G_UID"

SHADOW_NAME_RESPONSE = "SHADOW_NAME:"
SHADOW_ALL_RESPONSE = "SHADOW_ALL"

PASSWD_ALL_RESPONSE = "PASSWD_ALL"
PASSWD_RESPONSE = "P"

REDIS_KEY_EXPIRY = 7 * 60
