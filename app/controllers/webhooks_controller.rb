# ================================================
# RUBY->CONTROLLER->WEBHOOKS-CONTROLLER ==========
# ================================================
class WebhooksController < ApplicationController

  # ----------------------------------------------
  # FILTERS --------------------------------------
  # ----------------------------------------------
  skip_before_action :require_login

  # ----------------------------------------------
  # PLAID-CALLBACK -------------------------------
  # ----------------------------------------------
  def plaid_callback
    puts "DID THIS HIT THE CALLBACK??"
  end

end
