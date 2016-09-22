require 'dwolla_swagger'

DwollaSwagger::Swagger.configure do |config|
  config.access_token = 'a token'
  # change to production when live
  config.host = 'api-uat.dwolla.com'
  config.base_path = '/'
end
