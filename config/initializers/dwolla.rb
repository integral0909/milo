require 'dwolla_v2'

$dwolla = DwollaV2::Client.new(id: ENV["DWOLLA_CLIENT_ID"], secret: ENV["DWOLLA_CLIENT_SECRET"]) do |config|
  if !Rails.env.production?
    config.environment = :sandbox
  end
end
