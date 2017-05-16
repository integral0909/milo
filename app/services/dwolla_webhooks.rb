module DwollaWebhooks
  def self.process_webhook_event(params, event)
    topic =  params['topic']

    case topic
    when 'customer_transfer_created' #when the users transfer to FBO is created
      # send email about transfer start

    when 'customer_transfer_completed' #when the users funds are successfully transfered to Shift FBO
      p "::::TRANSFER COMPLETE::::::::"
      p "#{event.user_id}"
      p "#{event['user_id']}"
      user = User.find(event.user_id)
      # set app token for Dwolla
      app_token = Dwolla.set_dwolla_token

      # Pull in transfer info from the webhook
      event_info = app_token.get event.response_id

      transfer_info = app_token.get event_info['_links']['resource']['href']

      p "::::TRANSFER INFO: #{transfer_info}::::::::"
      transfer_type = transfer_info[:metadata][:transfer_type]

      p "::::TRANSFER TYPE: #{transfer_type}::::::::"
      # amount to increase or decrease user's account by
      amount = transfer_info[:amount][:value]
      p "::::TRANSFER AMOUNT #{amount}::::::::"
      if transfer_type == "withdaw"
        User.decrease_account_balance(user, amount)
      else
        if transfer_type == "quick-save"
          p "::::TRANSFER quick-save::::::::"
        # add the quick save amount from the user's account balance
          begin
            User.add_account_balance(user, amount, true)

            BankingMailer.quick_save_success(user, amount).deliver_now
          rescue => e
            SupportMailer.quick_save_failed(user, amount, e).deliver_now
          end


        else
          User.add_account_balance(user, amount)
        end

        # send email to user about funds being transfered to their account.
        BankingMailer.quick_save_success(user, amount).deliver_now
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