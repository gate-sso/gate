begin
  Dotenv.require_keys('GATE_DB_HOST',
    'GATE_DB_PORT',
    'GATE_DB_USER',
    'GATE_DB_PASSWORD',
    'CACHE_HOST',
    'CACHE_PORT',
    'GATE_HOSTED_DOMAINS',
    'GATE_HOSTED_DOMAIN')
rescue => exception
  puts exception.to_s
  exit(-1)
end
