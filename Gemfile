source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'pry-rails'
gem 'pg'
gem 'nokogiri'
gem 'mechanize'
gem 'sidekiq'
gem 'redis'
gem 'html2text'
gem 'redis-objects'
gem 'connection_pool'

gem 'rails', '~> 6.0.0'
gem 'puma', '~> 3.11'
gem 'sass-rails', '~> 5'
gem 'webpacker', '~> 4.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'dotenv-rails'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'foreman'
gem "barnes"
gem 'newrelic_rpm'

group :development, :test do
  gem 'rubocop-rails'
  gem 'rspec-rails'
  gem 'sqlite3', '~> 1.4'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'

  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'solargraph'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
