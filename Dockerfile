FROM jruby:9.1-alpine
LABEL maintainer <vjdhama26@gmail.com>

RUN mkdir /app

WORKDIR /app

COPY Gemfile /app
COPY Gemfile.lock /app

RUN apk --update add build-base nodejs mariadb-dev mariadb-client-libs tzdata && \
    bundle install && \
    apk del build-base mariadb-dev && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

ADD . /app

EXPOSE 3000

#ENTRYPOINT [ "./entrypoint.sh"]

