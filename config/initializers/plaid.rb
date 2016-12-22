Plaid.config do |p|
  p.client_id = ENV['PLAID_CLIENT_ID']   # Client ID from Plaid
  p.secret = ENV['PLAID_SECRET']           # Secret from Plaid
  if Rails.env.production?
    p.env = :production
  else
    p.env = :tartan
  end
end
