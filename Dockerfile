FROM ruby:2.4

RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
RUN apt-get update -qq && apt-get install -y build-essential nodejs git

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app
COPY Gemfile.lock /app

RUN gem install bundler -v 1.17.3
RUN bundle install --without development
COPY . /app

CMD [ "bundle", "exec", "rails", "s" ]
