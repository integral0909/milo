require 'dwolla_v2'

$dwolla = DwollaV2::Client.new(id: ENV["DWOLLA_CLIENT_ID"], secret: ENV["DWOLLA_CLIENT_SECRET"]) do |config|
  config.environment = :sandbox

  # whenever a token is granted, save it to ActiveRecord
  config.on_grant do |token|
    TokenData.create! token
  end
end

# create an application token if one doesn't already exist
begin
  TokenData.fresh_token_by! account_id: nil
rescue ActiveRecord::RecordNotFound => e
  $dwolla.auths.client # this gets saved in our on_grant callback
end

# create an account token if one doesn't already exist
# begin
#   TokenData.fresh_token_by! account_id: ENV["DWOLLA_ACCOUNT_ID"]
# rescue ActiveRecord::RecordNotFound => e
#   TokenData.create! account_id: ENV["DWOLLA_ACCOUNT_ID"],
#                     refresh_token: ENV["DWOLLA_ACCOUNT_REFRESH_TOKEN"],
#                     expires_in: -1
# end
