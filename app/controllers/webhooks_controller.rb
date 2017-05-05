# ================================================
# RUBY->CONTROLLER->WEBHOOKS-CONTROLLER ==========
# ================================================
class WebhooksController < ApplicationController

  # ----------------------------------------------
  # FILTERS --------------------------------------
  # ----------------------------------------------
  skip_before_action :require_login, :verify_authenticity_token



  # ----------------------------------------------
  # PLAID-CALLBACK -------------------------------
  # ----------------------------------------------
  def plaid_callback
    puts "DID THIS HIT THE CALLBACK??"
  end

# TODO: create DwollEvent model and add event_id. Check if the event id is already present in any object. If yes, don't run the event.
  def dwolla_webhook
    verify_signature

    puts "Dwolla hook called"
    DwollaWebhooks.process_webhook_event(params)

    render :nothing => true
  end

  private

  def verify_signature(payload_body, request_signature)
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), ENV["DWOLLA_WEBHOOK_SECRET"], payload_body)
    unless Rack::Utils.secure_compare(signature, request_signature)
      halt 500, "Signatures didn't match!"
    end
  end

end
