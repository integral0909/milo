require 'resque'

# ================================================
# RUBY->DWOLLA-SERVICE ===========================
# ================================================
module Dwolla

  # ----------------------------------------------
  # INCLUDES -------------------------------------
  # ----------------------------------------------
  include TokenConcern
  include ActionView::Helpers::NumberHelper

  # ----------------------------------------------
  # CREATE-DWOLLA-USER ---------------------------
  # ----------------------------------------------
  def self.create_user(user)
    Resque.enqueue(AddDwollaUserJob, user.id)
  end

  # ----------------------------------------------
  # CONNECT-FUNDING-SOURCE -----------------------
  # ----------------------------------------------
  # Add funding source for user to Dwolla
  def self.connect_funding_source(user)
    Resque.enqueue(AddDwollaFundingSourceJob, user.id)
  end

  def self.init_micro_deposits(user, user_checking, funding_account)
    begin
      Dwolla.set_dwolla_token

      @dwolla_app_token.post "#{user.dwolla_funding_source}/micro-deposits"

      BankingMailer.longtail_account_added(user, funding_account).deliver_now

      user.queue_longtail_drip_emails(user, funding_account)
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
      tuesday = current_date.beginning_of_week(start_day = :tuesday)
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
            .where("date > ?", tuesday)
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
    rescue => e
      # EMAIL: if all round up task breaks
      puts e
    end
  end

  # ----------------------------------------------
  # WITHDRAW-ROUNDUPS ----------------------------
  # ----------------------------------------------
  # add the users funding source, our account number, and the total roundup amount
  def self.withdraw_roundups(user, roundup_amount, total_transactions, funding_account, current_date)
    @charge_tech_fee = false

    # if it's the first round up of the month, the user is not an admin and the user is not associated with a business, charge the tech fee.
    @charge_tech_fee = true if ((current_date.day <= 7) && !user.admin && user.business_id.nil? )

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
            :href => "https://api-uat.dwolla.com/funding-sources/#{ENV["DWOLLA_FUNDING_SOURCE_FBO"]}"
          }
        },
        :amount => {
          :currency => "USD",
          :value => (@charge_tech_fee ? roundup_with_fee : roundup_amount)
        },
        :metadata => {
          :customerId => user.id,
          :transferType => ENV['DWOLLA_ROUNDUP'],
          :techFeeCharged => "#{@charge_tech_fee}"
        }
      }

      Dwolla.set_dwolla_token
      transfer = @dwolla_app_token.post "transfers", request_body
      current_transfer_url = transfer.headers[:location]

      # Get the status of the current transfer
      Dwolla.set_dwolla_token
      transfer_status = @dwolla_app_token.get current_transfer_url
      current_transfer_status = transfer_status['status']

      # Save transfer data
      Transfer.create_transfers(user, "", current_transfer_url, current_transfer_status, roundup_amount, total_transactions, "deposit", current_date, @charge_tech_fee)

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

  # Charge tech fee for all employees associated with the business
  def self.charge_biz_tech_fee(biz, user, checking)
    employee_count = User.where(business_id: biz.id).count
    fee_amount = number_to_currency((employee_count * 3), unit:"")

    begin
      request_body = {
        :_links => {
          :source => {
            :href => user.dwolla_funding_source
          },
          :destination => {
            :href => "https://api-uat.dwolla.com/funding-sources/#{ENV["DWOLLA_FUNDING_SOURCE_CORP"]}"
          }
        },
        :amount => {
          :currency => "USD",
          :value => fee_amount
        },
        :metadata => {
          :bizId => biz.id,
          :transferType => "biz tech fee"
        }
      }

      # Create Dwolla token and make the transfer request
      Dwolla.set_dwolla_token
      transfer = @dwolla_app_token.post "transfers", request_body
      current_transfer_url = transfer.headers[:location]

      # Get the status of the current transfer
      Dwolla.set_dwolla_token
      transfer_status = @dwolla_app_token.get current_transfer_url
      current_transfer_status = transfer_status['status']

      # Save transfer data
      Transfer.create_transfers(user, biz.id, current_transfer_url, current_transfer_status, fee_amount, "", "deposit", Date.today, true)

      puts "$#{fee_amount}"

      # TODO: this needs to happen when we get the customer_transfer_completed webhook response

      # Email the user that the tech fee was successfully charged
      BankingMailer.biz_tech_fee_success(user, fee_amount).deliver_now
    rescue => e
      # TODO: this needs to happen when we get the customer_transfer_failed webhook response
      # Email the user that there was an issue when withdrawing the round up
      BankingMailer.biz_tech_fee_failed(user, fee_amount).deliver_now
      # Email support that there was an issue when withdrawing the round up
      SupportMailer.support_transfer_failed_notice(user, fee_amount, e).deliver_now
    end
  end

  # Charge tech fee for all employees associated with the business
  def self.withdraw_employer_contribution
    Business.all.each do |biz|
      # only run withdraw if employer has contributions
      if biz.current_contribution

        # check if owner exists
        if !User.exists?(biz.owner)
          next
        end

        biz_owner = User.find(biz.owner)
        ck = Checking.find_by_user_id(biz_owner.id)
        # convert to dollars since we save in cents
        contribution = number_to_currency((biz.current_contribution.to_f / 100), unit:"")
        begin
          request_body = {
            :_links => {
              :source => {
                :href => biz_owner.dwolla_funding_source
              },
              :destination => {
                :href => "https://api-uat.dwolla.com/funding-sources/#{ENV["DWOLLA_FUNDING_SOURCE_FBO"]}"
              }
            },
            :amount => {
              :currency => "USD",
              :value => contribution
            },
            :metadata => {
              :bizId => biz.id,
              :transferType => "employer contribution"
            }
          }

          # Create Dwolla token and make the transfer request
          Dwolla.set_dwolla_token
          transfer = @dwolla_app_token.post "transfers", request_body
          current_transfer_url = transfer.headers[:location]

          # Get the status of the current transfer
          Dwolla.set_dwolla_token
          transfer_status = @dwolla_app_token.get current_transfer_url
          current_transfer_status = transfer_status['status']

          # Save transfer data
          Transfer.create_transfers(biz_owner, biz.id, current_transfer_url, current_transfer_status, contribution, "", "deposit", Date.today, true)

          puts "Employer contribution: $#{contribution}"

          # TODO: this needs to happen when we get the customer_transfer_completed webhook response

          # Email the user that the tech fee was successfully charged
          BankingMailer.biz_contributions_successful(biz, biz_owner, contribution).deliver_now
          # reset current_contribution to nil.
          Business.reset_current_contribution(biz.id)
        rescue => e
          # TODO: this needs to happen when we get the customer_transfer_failed webhook response

          # Email the user that there was an issue when withdrawing the round up
          BankingMailer.biz_contributions_failed(biz, biz_owner, contribution).deliver_now
          # Email support that there was an issue when withdrawing the round up
          SupportMailer.support_biz_contributions_failed(biz, contribution, e).deliver_now
        end
      end
    end
  end

   # ----------------------------------------------
   # SEND-FUNDS-TO-USER ---------------------------
   # ----------------------------------------------
   # send funds the user requested to withdraw
   def self.send_funds_to_user(user, requested_amount)
       Resque.enqueue(DwollaSendFundsToUserJob, user.id, requested_amount)
   end

   def self.last_transfer_processed(user)
     last_transfer = Transfer.where(user_id: user.id).last

     #find last transfer to make sure it's not pending. All transfers need to be processed before they can take out their funds.
     Dwolla.set_dwolla_token

     transfer = @dwolla_app_token.get "#{ENV['DWOLLA_BASE_URL']}#{last_transfer.dwolla_url}"

     transfer_status = transfer['status']
     return true if transfer_status == "processed"
   end

  #  def self.transfer_tech_fee_to_corp(fee_amount)
  #    begin
  #      current_date = Date.today
  #      transfer_request = {
  #        :_links => {
  #          :source => {
  #            :href => "https://api-uat.dwolla.com/funding-sources/#{ENV["DWOLLA_FUNDING_SOURCE_FBO"]}"
  #          },
  #          :destination => {
  #            :href => "https://api-uat.dwolla.com/funding-sources/#{ENV["DWOLLA_FUNDING_SOURCE_CORP"]}"
  #          }
  #        },
  #        :amount => {
  #          :currency => "USD",
  #          :value => "9.00"
  #        },
  #        :metadata => {
  #          :tech_fee_date => current_date
  #        }
  #      }
  #      Dwolla.set_dwolla_token
  #      # Using DwollaV2 - https://github.com/Dwolla/dwolla-v2-ruby (Recommended)
  #      transfer = @dwolla_app_token.post "transfers", transfer_request
  #      "#{fee_amount} transfered from FBO to the CORP account"
  #    rescue => e
  #      puts e
  #      # send email to dev team about failed transfer to user
  #     #  SupportMailer.tech_fee_transfer_failed(fee_amount, e).deliver_now
  #    end
  #  end

  def self.quick_save(user, amount)
    Resque.enqueue(DwollaQuickSaveJob, user.id, amount)
  end

  # reset the dwolla app token
  def self.set_dwolla_token
    @dwolla_app_token.nil? ? @dwolla_app_token = $dwolla.auths.client : @dwolla_app_token
  end
end
