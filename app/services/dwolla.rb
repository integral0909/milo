# All Dwolla functionality will be held here
module Dwolla
  include TokenConcern


    # Create user on Dwolla
    def self.create_user(user)
      begin
        # We don't save name in 2 seperate fields so append -Milo to the name
        # TODO: add :ip_address => to customer creation with request.remote_ip
        request_body = {
          :firstName => user.name,
          :lastName => '-Milo',
          :email => user.email
        }

        # Using DwollaSwagger - https://github.com/Dwolla/dwolla-swagger-ruby
        dwolla_customer_url = TokenConcern.account_token.post "customers", request_body
        puts "Adding dwolla url to user"
        ap dwolla_customer_url

        # Add dwolla customer URL to the user
        user = User.find(user.id)
        user.dwolla_id = dwolla_customer_url.headers[:location]
        user.save!
      rescue => e
        p e
        # Let user go through to the welcome screen but send email with error from dwolla
        return
      end
    end

    # Add funding source for user to Dwolla
    def self.connect_funding_source(user)
      begin
        # Find the checking account associated with the user
        user_checking = Checking.find_by_user_id(user.id)
        # Get the info from the Account to add a funding source to Dwolla
        funding_account = Account.find_by_plaid_acct_id(user_checking.plaid_acct_id)

        dwoll_customer_url = user.dwolla_id
        request_body = {
          routingNumber: funding_account.bank_routing_number,
          accountNumber: funding_account.bank_account_number,
          type: funding_account.acct_subtype,
          name: funding_account.name
        }

        funding_source = TokenConcern.account_token.post "#{dwolla_customer_url}/funding-sources", request_body

        # Add the funding source to the user
        user = User.find(user.id)
        user.dwolla_funding_source = funding_source.headers[:location]
        user.save!
      rescue => e
        p e
        # Let user go through to the home screen but send email with error from dwolla
        return
      end
    end

    # recieve a total of all transations from each user
    def self.weekly_roundup
      # set last weeks date
      current_date = Date.today
      last_week_date = current_date - 1.week


      # loop through all CHECKING accounts connected with Milo
      Checking.all.each do |ck|
        # Find user based on checking.user_id
        user = User.find(ck.user_id)
        # find all transactions where transaction.account_id = ck.plaid_acct_id & pending = false OR transaction.user_id once it's added && within the last week
        transactions = Transaction.where(account_id == ck.plaid_acct_id && pending == false && date > last_week_date )
        ####### total the roundups
        # set variable for roundup_total
        roundup_total = 0
        # go through transactions and add transaction.roundup to the total
        transactions.each do |trns|
          roundup_total += trns.roundup
        end

        # account = Account.where(plaid_acct_id = ck.plaid_acct_id) should be 1
        account = Account.where(plaid_acct_id == ck.plaid_acct_id)

        # send the total amount to Dwolla
        withdraw_roundups(user, roundup_total.round(2), transactions.count )

        # on success => update the transaction with roundup 0.00 or rounded up. Also update total roundups on the user -> this will be where we know how much they have in their account.

        # send email to user with weekly data and how much they have in their account
      end
    end

    # add the users funding source, our account number, and the total roundup ammount
    def withdraw_roundups(user, roundup_ammount, transaction_total)
      request_body = {
        :_links => {
          :source => {
            :href => user.dwolla_funding_source
          },
          :destination => {
            :href => "https://api-uat.dwolla.com/accounts/#{ENV["DWOLLA_ACCOUNT_ID"]}"
          }
        },
        :amount => {
          :currency => "USD",
          :value => roundup_ammount
        },
        :metadata => {
          :user_id => user.id,
          :total_transactions => transaction_total
        }
      }
      # Create Transaction object to save the data returned
      transfer = TokenConcern.account_token.post "transfers", request_body
      current_transfer_url = transfer.headers[:location]

      # Get the status of the current transfer
      transfer_status = TokenConcern.account_token.get current_transfer_url
      current_transfer_status = transfer_status.status

      # Save transfer data
      Transfer.create_transfer_on_roundup(user, current_transfer_url, current_transfer_status, roundup_ammount, roundup_count, "deposit")

    end

    # TODO: create recurring fee for $1 tech fee
    # def self.monthly_tech_fee
    #   request_body
    # end

end
