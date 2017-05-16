module DwollaWebhooks
  def self.process_webhook_event(params, event)
    begin
      topic =  params['topic']

      case topic
      when 'customer_transfer_created' #when the users transfer to FBO is created
        # send email about transfer start

      when 'customer_transfer_completed' #when the users funds are successfully transfered to Shift FBO
        p "::::TRANSFER COMPLETE::::::::"

        user = User.find(event.user_id)

        # set app token for Dwolla
        @app_token = Dwolla.set_dwolla_token

        DwollaWebhooks.pull_event_info(event)

        if transfer_type == ENV['DWOLLA_WITHDRAW']

          # decrease the requested amount from the user's account balance
          User.decrease_account_balance(user, @amount)

        else
          if transfer_type == ENV['DWOLLA_QUICK_SAVE']

            p "::::TRANSFER #{ENV['DWOLLA_QUICK_SAVE']}::::::::"

            # add the quick save amount from the user's account balance
            begin
              User.add_account_balance(user, @amount, true)

              BankingMailer.quick_save_success(user, @amount).deliver_now
            rescue => e
              SupportMailer.quick_save_failed(user, @amount, e).deliver_now
            end

          elsif transfer_type == ENV['DWOLLA_ROUNDUP']
            begin
              # add the roundup amount to the users balance
              User.add_account_balance(user, roundup_amount)

              funding_account  = Checking.find_by_user_id(user.id)

              puts "$#{@amount}"

              # Email the user that the round up was successfully withdrawn
              BankingMailer.transfer_success(user, @amount, funding_account, @tech_fee_charged).deliver_now
            rescue => e
              # Email the user that there was an issue when withdrawing the round up
              BankingMailer.transfer_failed(user, @amount, funding_account).deliver_now

              # Email support that there was an issue when withdrawing the round up
              SupportMailer.support_transfer_failed_notice(user, @amount, e).deliver_now
            end
          end
        end

      when 'customer_transfer_failed' #when the users funds fail to transfer to Shift FBO
        # send failed transfer email to support

      when 'bank_transfer_created' #when the user withdraw is created


      when 'bank_transfer_completed' #when the user withdraw is completed


      when 'bank_transfer_failed' #when the user withdraw fails
        # send failed transfer email to support
        SupportMailer.bank_transfer_failed(event, e)
      end
    rescue => e
      SupportMailer.dwolla_webhook_failed(event, e)
    end
  end

  def self.pull_event_info(event)

    # Pull in transfer info from the webhook
    @event_info = @app_token.get event.response_id

    transfer_info = @app_token.get event_info['_links']['resource']['href']

    @transfer_type = transfer_info[:metadata][:transfer_type]

    @tech_fee_charged = transfer_info[:metadata][:tech_fee_charged]

    # amount to increase or decrease user's account by
    @amount = transfer_info[:amount][:value]
  end
end
