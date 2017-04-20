source 'https://rubygems.org'

# Core
# TODO:when upgrading to rails 5.0+, remove below plus vendor/gems
gem 'activesupport', :path => File.join(File.dirname(__FILE__), '/vendor/gems/activesupport-4.2.7.1')
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.7.1'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc

# bootstrap for stylesheets
gem 'bootstrap', '4.0.0.alpha3'
# Tooltips and popovers depend on tether
gem 'rails-assets-tether', '1.1.1'

# SEO
gem 'meta-tags'
gem 'social-share-button'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# API
gem 'doorkeeper'
#gem 'rack-cors', :require => 'rack/cors'
#gem 'active_hash_relation', github: 'kollegorna/active_hash_relation'
#gem 'pundit', '~> 0.3.0'
#gem 'active_model_serializers', '0.9.2'
gem 'kaminari', '~> 0.17.0'
gem 'redis-throttle', git: 'https://github.com/andreareginato/redis-throttle.git'

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
gem 'plaid', '3.0.0'

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
gem 'week_of_month', git: 'https://github.com/kobaltz/week-of-month.git'

# for background jobs
gem 'redis'
gem 'resque'
gem 'resque-scheduler'
gem 'resque_mailer'

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

  # startup with procfile
  gem 'foreman'

end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Better Error Messages
  gem 'better_errors'

  # Annotate Models
  gem 'annotate'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end
