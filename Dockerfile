FROM ruby:2.6.3-alpine3.10 as BUILDER 
MAINTAINER Carlos Ortega <corteg20@gmail.com>

WORKDIR /var/www/rate_server

RUN apk add --update alpine-sdk mariadb-dev tzdata \
  && rm -f /var/cache/apk/*

ENV RAILS_ENV production

COPY Gemfile /var/www/rate_server/Gemfile
COPY Gemfile.lock /var/www/rate_server/Gemfile.lock

RUN gem install bundler:2.0.2
RUN bundle install --without development test

COPY . /var/www/rate_server

EXPOSE 3000

CMD ["bundle", "exec", "rails", "s"]
