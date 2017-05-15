module DwollaWebhooks
  def self.process_webhook_event(params, event)
    topic =  params['topic']

    case topic
    when 'customer_transfer_created' #when the users transfer to FBO is created
      # send email about transfer start

    when 'customer_transfer_completed' #when the users funds are successfully transfered to Shift FBO
      # send email about transfer completed, update users account balance at this point
      user = User.find(event.user_id)

      # set app token for Dwolla
      app_token = Dwolla.set_dwolla_token

      # Pull in transfer info from the webhook
      transfer_info = app_token.get event["_links"]["resource"]["href"]

      transfer_type = transfer_info['metadata']['transfer_type']

      # amount to increase or decrease user's account by
      amount = transfer_info["amount"]["value"]

      if transfer_type == "withdaw"
        User.decrease_account_balance(user, amount)
      else
        User.add_account_balance(user, amount)
      end

    when 'customer_transfer_failed' #when the users funds fail to transfer to Shift FBO
      # send failed transfer email to user

    when 'bank_transfer_created' #when the user withdraw is created


    when 'bank_transfer_completed' #when the user withdraw is completed


    when 'bank_transfer_failed' #when the user withdraw fails
      # send failed transfer email to support

    end
  end

  def self.pull_event_info

  end
end
