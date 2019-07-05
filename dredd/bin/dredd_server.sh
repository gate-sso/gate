#!/bin/bash
# dredd_server.sh
kill -9 $(lsof -i tcp:9865 -t)
export RAILS_ENV=test
export LOG_LEVEL=info
bundle exec rails server --port=9865

