FROM ruby:2.6.3

# -----------------------------
# START DEPS

RUN apt-get update -qq && apt-get install -y nodejs postgresql-client
# for postgres
RUN apt-get install -y libpq-dev
# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev
# for bundler
RUN gem install bundler:2.0.2

# END DEPS
# -----------------------------

# -----------------------------
# START FILES

WORKDIR /dex-rails

COPY Gemfile ./
COPY Gemfile.lock ./


RUN bundle install --deployment --without development test

COPY . .

# END FILES


ENV RAILS_ENV production

EXPOSE 3000
ENTRYPOINT ./entrypoint.sh

CMD ["rails", "server", "-b", "0.0.0.0"]
