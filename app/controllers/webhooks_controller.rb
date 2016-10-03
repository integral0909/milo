class WebhooksController < ApplicationController
  skip_before_action :require_login

  def plaid_callback
    puts "DID THIS HIT THE CALLBACK??"
  end

end
