begin
Figaro.require_keys('GATE_DB_HOST',
                    'GATE_DB_PORT',
                    'GATE_DB_USER',
                    'GATE_DB_PASSWORD',
                    'CACHE_HOST',
                    'CACHE_PORT',
                    'GATE_HOSTED_DOMAINS',
                    'GATE_HOSTED_DOMAIN',
                    'GATE_SAML_IDP_X509_CERTIFICATE',
                    'GATE_SAML_IDP_SECRET_KEY')
rescue => e
  puts e.to_s
  exit -1
end
