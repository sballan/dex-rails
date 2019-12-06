# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'connection_pool'
gem 'html2text'
gem 'mechanize'
gem 'nokogiri'
gem 'pg'
gem 'pry-rails'
gem 'redis'
gem 'redis-objects'
gem 'sidekiq'

gem 'dotenv-rails'
gem 'jbuilder', '~> 2.7'
gem 'puma', '~> 3.11'
gem 'rails', '~> 6.0.0'
gem 'sass-rails', '~> 5'
gem 'turbolinks', '~> 5'
gem 'webpacker', '~> 4.0'

gem 'barnes'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'foreman'

group :development, :test do
  gem 'rspec-rails'
  gem 'rubocop-rails'
  gem 'sqlite3', '~> 1.4'
  gem 'rack-mini-profiler'

  # For memory profiling
  gem 'memory_profiler'

  # For call-stack profiling flamegraphs
  gem 'flamegraph'
  gem 'stackprof'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'

  gem 'solargraph'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
