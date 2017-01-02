# ================================================
# RUBY->DWOLLA-SERVICE ===========================
# ================================================
module Dwolla

  # ----------------------------------------------
  # INCLUDES -------------------------------------
  # ----------------------------------------------
  include TokenConcern

  # ----------------------------------------------
  # CREATE-DWOLLA-USER ---------------------------
  # ----------------------------------------------
  def self.create_user(user)
    begin
      # We don't save name in 2 seperate fields so append -Milo to the name
      # TODO: add :ip_address => to customer creation with request.remote_ip
      request_body = {
        :firstName => user.name,
        :lastName => '-Milo',
        :email => user.email
      }

      Dwolla.set_dwolla_token
      dwolla_customer_url = @dwolla_app_token.post "customers", request_body

      # Add dwolla customer URL to the user
      user = User.find(user.id)
      user.dwolla_id = dwolla_customer_url.headers[:location]
      user.save!
    rescue => e
      # EMAIL: send support the error from
      SupportMailer.add_dwolla_user_failed(user, e).deliver_now
      return
    end
  end

  # ----------------------------------------------
  # CONNECT-FUNDING-SOURCE -----------------------
  # ----------------------------------------------
  # Add funding source for user to Dwolla
  def self.connect_funding_source(user)
    begin
      # Find the checking account associated with the user
      user_checking = Checking.find_by_user_id(user.id)
      # Get the info from the Account to add a funding source to Dwolla
      funding_account = Account.find_by_plaid_acct_id(user_checking.plaid_acct_id)

      dwolla_customer_url = user.dwolla_id
      request_body = {
        routingNumber: funding_account.bank_routing_number,
        accountNumber: funding_account.bank_account_number,
        type: funding_account.acct_subtype,
        name: funding_account.name,
        verified: (user.long_tail ? false : true)
      }
      Dwolla.set_dwolla_token
      funding_source = @dwolla_app_token.post "#{dwolla_customer_url}/funding-sources", request_body

      # Add the funding source to the user
      user = User.find(user.id)
      user.dwolla_funding_source = funding_source.headers[:location]
      user.save!

      if user.long_tail
        Dwolla.init_micro_deposits(user, user_checking, funding_account)
      else
        BankingMailer.account_added(user, funding_account).deliver_now
      end
    rescue => e
      # EMAIL: send support the error from Dwolla
      SupportMailer.connect_funding_source_failed(user, user_checking, funding_account, e).deliver_now
    end
  end

  def self.init_micro_deposits(user, user_checking, funding_account)
    begin
      Dwolla.set_dwolla_token
      @dwolla_app_token.post "#{user.dwolla_funding_source}/micro-deposits"

      BankingMailer.longtail_account_added(user, funding_account).deliver_now
    rescue => e
      # EMAIL: send support the error from Dwolla
      SupportMailer.connect_funding_source_failed(user, user_checking, funding_account, e).deliver_now
    end
  end

  # confirm micro-deposits for long_tail accounts
  def self.confirm_micro_deposits(deposit1, deposit2, user, account)
    begin
      request_body = {
        :amount1 => {
          :value => deposit1,
          :currency => "USD"
        },
        :amount2 => {
          :value => deposit2,
          :currency => "USD"
        }
      }

      # Using DwollaV2 - https://github.com/Dwolla/dwolla-v2-ruby
      Dwolla.set_dwolla_token
      @dwolla_app_token.post "#{user.dwolla_funding_source}/micro-deposits", request_body

      User.bank_verified(user)
    rescue =>  e
      # status will be 400 if the deposits are incorrect
      if e.status == 400
        # if user inputs wrong deposit amounts
        Account.micro_deposit_verification_failed(account, user)
      end
      puts "-" * 50
      puts e
    end
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # WEEKLY-ROUNDUP -------------------------------
  # ----------------------------------------------
  # recieve a total of all transations from each user
  def self.weekly_roundup(user, checking)
    begin
      # set beginning of the week
      current_date = Date.today
      sunday = current_date.beginning_of_week(start_day = :sunday)
        puts "-"*40
        puts "User #{user.id} Roundups"

        if user.dwolla_funding_source.blank?
          puts "Createing Dwolla funding source"
          # connect Dwolla funding source and send email
          Dwolla.connect_funding_source(user)
        end

        begin

          # find all transactions where transaction.account_id = ck.plaid_acct_id & pending = false OR transaction.user_id once it's added && within the last week
          transactions = Transaction
            .where(:account_id => checking.plaid_acct_id, :pending => false)
            .where("date > ?", sunday)
            # TODO :: DWOLLA TESTING FOR SUCCESS


          ####### total the roundups
          # set variable for roundup_total
          roundup_total = 0
          # go through transactions and add transaction.roundup to the total
          transactions.each do |trns|
            roundup_total += trns.roundup
          end

          # on success => update the transaction with roundup 0.00 or rounded up. Also update total roundups on the user -> this will be where we know how much they have in their account <= IMPORTANT: Backup on gathering total roundups for a user is to query the Transfer with the user's id
          if roundup_total > 0 && transactions.count > 0
            roundup_total = number_to_currency(roundup_total.round(2), unit:"")
            withdraw_roundups(user, roundup_total, transactions.count, checking, current_date)
          end

          # send email to user with weekly data and how much they have in their account
        rescue => e
          puts e
          # EMAIL: send us an email if a user's roundup task fails
        end
    rescue ExceptionName
      # EMAIL: if all round up task breaks
      puts ExceptionName
    end
  end

  # ----------------------------------------------
  # WITHDRAW-ROUNDUPS ----------------------------
  # ----------------------------------------------
  # add the users funding source, our account number, and the total roundup amount
  def self.withdraw_roundups(user, roundup_amount, total_transactions, funding_account, current_date)
    @charge_tech_fee = false

    # if it's the first round up of the month and the user is not an admin, charge the tech fee.
    @charge_tech_fee = true  if ((current_date.day <= 7) && !user.admin)

    BankingMailer.transfer_start(user, roundup_amount, funding_account, @charge_tech_fee).deliver_now
    begin
      # Add $1 for the tech fee
      roundup_with_fee = number_to_currency((roundup_amount.to_f + 1.00), unit:"")

      request_body = {
        :_links => {
          :source => {
            # TODO :: DWOLLA TESTING FOR FAILURE
            :href => user.dwolla_funding_source
          },
          :destination => {
            :href => "https://api-uat.dwolla.com/accounts/#{ENV["DWOLLA_ACCOUNT_ID"]}"
          }
        },
        :amount => {
          :currency => "USD",
          :value => (@charge_tech_fee ? roundup_with_fee : roundup_amount)
        },
        :metadata => {
          :user_id => user.id,
          :total_transactions => total_transactions,
          :date => current_date,
          :tech_fee_charged => @charge_tech_fee
        }
      }
      Dwolla.set_dwolla_token
      transfer = @dwolla_app_token.post "transfers", request_body
      current_transfer_url = transfer.headers[:location]

      # Get the status of the current transfer
      Dwolla.set_dwolla_token
      transfer_status = @dwolla_app_token.get current_transfer_url
      current_transfer_status = transfer_status.status

      # Save transfer data
      Transfer.create_transfers(user, current_transfer_url, current_transfer_status, roundup_amount, total_transactions, "deposit", current_date, @charge_tech_fee)

      # add the roundup amount to the users balance
      User.add_account_balance(user, roundup_amount)

      puts "$#{roundup_amount}"

      # Email the user that the round up was successfully withdrawn
      BankingMailer.transfer_success(user, roundup_amount, funding_account, @charge_tech_fee).deliver_now
    rescue => e
      # Email the user that there was an issue when withdrawing the round up
      BankingMailer.transfer_failed(user, roundup_amount, funding_account).deliver_now
      # Email support that there was an issue when withdrawing the round up
      SupportMailer.support_transfer_failed_notice(user, roundup_amount, e).deliver_now
    end
  end

  # Remove funding source from Dwolla
  def self.remove_funding_source(user)
    begin
      request_body = {
        :removed => true
      }
      Dwolla.set_dwolla_token
      @dwolla_app_token.post user.dwolla_funding_source, request_body

      d_user = User.find(user.id)
      d_user.dwolla_funding_source = ''
      d_user.save!

      # Find the checking account associated with the user
      user_checking = Checking.find_by_user_id(user.id)
      # Get the info from the Account to add a funding source to Dwolla
      funding_account = Account.find_by_plaid_acct_id(user_checking.plaid_acct_id)

      BankingMailer.bank_account_removed(user, funding_account).deliver_now
    rescue =>  e
      puts e
    #  send account removal failure email
    end
  end

  def self.send_funds_to_user(user, requested_amount)
    begin
      transfer_request = {
        :_links => {
          :source => {
            :href => "https://api-uat.dwolla.com/accounts/#{ENV["DWOLLA_ACCOUNT_ID"]}"
          },
          :destination => {
            :href => user.dwolla_id
          }
        },
        :amount => {
          :currency => "USD",
          :value => requested_amount
        },
        :metadata => {
          :customerId => user.id,
        }
      }

      Dwolla.set_dwolla_token
      # Using DwollaV2 - https://github.com/Dwolla/dwolla-v2-ruby (Recommended)
      transfer = account_token.post "transfers", transfer_request
      # send email to user about funds being transfered to their account.
    rescue

    end
  end

  # reset the dwolla app token
  def self.set_dwolla_token
    @dwolla_app_token.nil? ? @dwolla_app_token = $dwolla.auths.client : @dwolla_app_token
  end

end
