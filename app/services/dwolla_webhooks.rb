module DwollaWebhooks
  def self.process_webhook_event(params, event)
    begin
      topic =  params['topic']

      case topic
      when 'customer_transfer_completed' #when the users funds are successfully transfered to Shift FBO
        p "::::TRANSFER COMPLETE::::::::"

        DwollaWebhooks.update_transfer_status(event)

        DwollaWebhooks.customer_transfer_completed(params, event)

      when 'customer_transfer_failed' #when the users funds fail to transfer to Shift FBO
        # send failed transfer email to support
        DwollaWebhooks.update_transfer_status(event)

        SupportMailer.transfer_failed(event, topic)

      when 'bank_transfer_failed' #when the user withdraw fails
        # send failed transfer email to support
        SupportMailer.transfer_failed(event, topic)

      when 'customer_microdeposits_failed' #when the user withdraw fails
        # send failed transfer email to support
        SupportMailer.transfer_failed(event, topic)
      end
    rescue => e
      SupportMailer.dwolla_webhook_failed(event, e)
    end
  end

  def self.customer_transfer_completed(params, event)

    user = User.find(event.user_id)

    DwollaWebhooks.pull_event_info(event)
    p @transfer_type
    if @transfer_type == ENV['DWOLLA_QUICK_SAVE']

      p "::::TRANSFER #{ENV['DWOLLA_QUICK_SAVE']}::::::::"

      # add the quick save amount from the user's account balance
      begin
        User.add_account_balance(user, @amount, true)

        BankingMailer.quick_save_success(user, @amount).deliver_now
      rescue => e
        SupportMailer.quick_save_failed(user, @amount, e).deliver_now
      end

    elsif @transfer_type == ENV['DWOLLA_ROUNDUP']
      begin
        p "::::TRANSFER #{ENV['DWOLLA_ROUNDUP']}::::::::"

        # add the roundup amount to the users balance
        User.add_account_balance(user, @amount)

        funding_account  = Checking.find_by_user_id(user.id)

        puts "$#{@amount}"

        # Email the user that the round up was successfully withdrawn
        BankingMailer.transfer_success(user, @amount, funding_account, false).deliver_now
      rescue => e
        # Email the user that there was an issue when withdrawing the round up
        BankingMailer.transfer_failed(user, @amount, funding_account).deliver_now

        # Email support that there was an issue when withdrawing the round up
        SupportMailer.support_transfer_failed_notice(user, @amount, e).deliver_now
      end
    end
  end

  def self.update_transfer_status(event)
    DwollaWebhooks.pull_event_info(event)

    transfer_id = Transfer.find_by_dwolla_url(@transfer_url).id

    Transfer.update_status(transfer_id, @transfer_info['status'])

  end

  def self.pull_event_info(event)
    begin
      p ":::PULLING EVENT INFO:::"
      # set app token for Dwolla
      @app_token = Dwolla.set_dwolla_token

      # Pull in transfer info from the webhook
      event_info = @app_token.get event.response_id

      @transfer_url = event_info['_links']['resource']['href']

      @transfer_info = @app_token.get @transfer_url
      p @transfer_info

      @transfer_type = @transfer_info[:metadata][:transferType]

      @tech_fee_charged = (@transfer_info[:metadata] && @transfer_info[:metadata][:techFeeCharged] && @transfer_info[:metadata][:techFeeCharged] == "false") ? false : true
      p @tech_fee_charged

      # amount to increase or decrease user's account by
      @amount = @transfer_info[:amount][:value]
    rescue => e
      SupportMailer.basic_error(e).deliver_now
    end
  end
end
