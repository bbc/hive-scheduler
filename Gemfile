source 'https://rubygems.org'

gem 'rails', '~> 4.2.10'
gem 'state_machine', :git =>"https://github.com/bbc/hive_state_machine.git"
gem 'jquery-rails'
gem 'sass-rails', '~> 4.0.0'
gem 'autoprefixer-rails'

gem 'bootstrap-sass', '< 3.3.0'
gem "bootstrap-switch-rails", '< 3.1.0'
gem 'font-awesome-sass' ,'4.2.0'
gem "select2-rails"

gem 'will_paginate', '~> 3.0'

# We should migrate from paperclip to ActiveStorage JG 5/8/18
#   See https://github.com/thoughtbot/paperclip/blob/master/MIGRATING.md
gem 'paperclip', '4.3.7'
gem 'aws-sdk', '~> 1.6'

gem 'chamber', '2.9.1'

gem 'chartjs-ror', '>= 3'
gem 'd3-rails', '~> 3.5'

gem 'omniauth' , '~> 1.3.2'

gem 'test_rail-api', '~> 0.4', require: 'test_rail'
gem 'mind_meld', '~> 0.1'
gem 'hive-messages', '~> 1.0', '>=1.0.7'

gem 'jbuilder'

gem 'imperator'
gem "cocoon"
gem 'simple_form', '~> 3.4'
gem "js-routes"
gem 'thin'

gem 'roar-rails'
gem 'paranoia', '~> 2.0.2'
gem "settingslogic"
gem 'sucker_punch', '~> 1.0'
gem "default_value_for", "~> 3.0.0"
gem 'cachethod', '~> 0.2.0'
gem 'image-picker-rails'
gem 'whenever', '~> 0.9', require: false

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'sqlite3'
end

group :test do
  gem 'rspec-rails', "2.14.2"
  gem 'fabrication', '< 2.11.0'
  gem 'shoulda-matchers', require: false
  gem 'forgery'
  gem "shoulda-callback-matchers", "~> 1.0"
  gem 'test_after_commit'
  gem 'timecop'
  gem 'database_cleaner'
  gem 'pry-byebug'
  gem 'codeclimate-test-reporter', require: nil
end

group :production do
  gem 'mysql2', '~> 0.3.18'
end

# Deprecated method used by other gems
gem 'rake', '< 12.0'
