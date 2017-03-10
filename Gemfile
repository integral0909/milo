source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.7.1'
# Use sqlite3 as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# bootstrap for stylesheets
gem 'bootstrap', '4.0.0.alpha3'
# Tooltips and popovers depend on tether
gem 'rails-assets-tether', '>= 1.1.0'

# SEO
gem 'meta-tags'
gem 'social-share-button'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# User Accounts with Devise
gem 'devise', '~> 4.2'
gem 'devise_invitable', '~> 1.7.0'

# Upload Images
gem 'paperclip'
gem 'aws-sdk', '~> 2.3'

# Mobile Phone Confirmation
gem 'twilio-ruby', '~> 4.0.0'
gem 'phonelib'

# Intercom
gem 'intercom-rails'
# Plaid API wrapper
gem 'plaid'

gem 'pry-rails'
gem 'json'
gem 'httparty'
gem 'hashie'

# Email
gem 'mail_form'
gem 'gibbon' # Mailchimp API Wrapper

# Slack Hooks
gem 'slack-notifier'

# to send pretty urls
gem 'bitly', '~> 0.10.4'

# admin console for easily viewing data
gem 'rails_admin'

# awesome print for better console logs
gem 'awesome_print', '~> 1.7'

# Dwolla v2 api wrapper for accepting money from users
gem 'dwolla_v2', '~> 1.1'

# gem "attr_encrypted"

# Checking for security flaws in code
gem "brakeman", :require => false

# Store sessions in Active Record instead of cookies
gem 'activerecord-session_store'

# helper to determain the week of the month, specific fork to resolve `beginning_of_week` conflict with gem
gem 'week_of_month', :git => 'https://github.com/kobaltz/week-of-month.git'

group :production, :staging do
  gem 'rails_12factor'
end

group :development, :test, :staging do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Test mailers in development
  gem 'letter_opener'

  # ENV variables
  gem 'dotenv-rails'

  # for testing
  gem 'rspec-rails', '~> 3.5'
  gem 'simplecov', :require => false

end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Better Error Messages
  gem 'better_errors'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end
