source 'https://rubygems.org'

gem 'middleman'
gem "middleman-blog"
gem 'middleman-minify-html'
gem 'concurrent-ruby', '>= 1.3.7' # 1.3.5+ dropped its Logger dependency; logger 1.7.0 is in the lock via hashie
gem 'nokogiri'
gem "middleman-syntax", "~> 3.4"
gem "redcarpet", "~> 3.6"
gem 'builder'
# Default gems removed in Ruby 4.0, still required by middleman's dependencies
# (ostruct <- servolux)
gem 'ostruct'

group :development do
  gem "pry"
  gem "byebug"
  gem "pry-byebug"
end
