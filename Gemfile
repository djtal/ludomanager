source 'https://rubygems.org'

gem "rails", "2.3.14"
gem 'mysql2', '~> 0.2.7'
gem "rake"

gem 'searchlogic', '2.4.12'
gem 'will_paginate', '~> 2.3.16'
gem 'paperclip', "~> 2.4"
gem 'by_star', '~>1.0.0'
gem 'simple_form', "~> 1.0.4"
#gem 'googlecharts', "~> 1.6.0"
gem "googlecharts", :git => "git://github.com/djtal/googlecharts.git"
#gem "googlecharts", :path => "../../googlecharts"
gem "rdoc"

gem 'newrelic_rpm'
gem 'foreman'

gem 'recap', '~>1.0.0'
gem 'aws-sdk'
gem 'nokogiri', '~>1.5.11' # because 1.6 require ruby 1.9?3 at least
gem 'capistrano', '~> 2.15.4'
gem 'whenever', '0.8.4', :require => false

group :test do
  gem 'shoulda', '2.10.3'
  gem 'factory_girl', '1.2.4'
end

group :development do
  gem "sqlite3-ruby", '~> 1.3.0', :require => "sqlite3"
  gem 'term-ansicolor'
  gem 'wirb'
  gem 'ruby-debug'
  gem 'rails-footnotes'
  gem 'thin'
end

group :production do
  gem "unicorn"
end
