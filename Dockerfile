FROM jruby:9.1.7.0
LABEL maintainer <vjdhama26@gmail.com>

RUN apt-get update -qq && apt-get install -y build-essential libmysqlclient-dev nodejs
RUN mkdir /app

WORKDIR /app

COPY Gemfile /app
COPY Gemfile.lock /app

RUN bundle install

ADD . /app

