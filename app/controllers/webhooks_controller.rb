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

    request_signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"),ENV["DWOLLA_WEBHOOK_SECRET"],params.to_s)

    verify_signature(params, request_signature)

    p "::::::::::::::::::::::DWOLLA WEBHOOK CALLED::::::::::::::::::::::::::::"

    # check if the webhook was already captured before processing.
    if WebhookEvent.find_by_response_id(params['_links']['resource']['href']).nil?
      create_event(params, 'Dwolla')

      DwollaWebhooks.process_webhook_event(params)
    end

    render :nothing => true
  end

  private

  def verify_signature(payload_body, request_signature)
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), ENV["DWOLLA_WEBHOOK_SECRET"], payload_body.to_s)
    unless Rack::Utils.secure_compare(signature, request_signature)
      halt 500, "Signatures didn't match!"
    end
  end

  def create_event(params, service)
    # Check if it's a customer related webhook event
    if params['_links']['customer']
      hook_user_id = User.find_by_dwolla_id(params['_links']['customer']['href']).id
    else
      # maybe do something else here but essentially this means it's a business related webhook
      hook_user_id = nil
    end

    data = {
        service: service,
        response_id: params['_links']['self']['href'],
        topic: params['topic'],
        user_id: hook_user_id
    }

    # create webhook event object
    WebhookEvent.create!(data)
  end

end
