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
        # EMAIL: send the error and the user that errored
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

        dwolla_customer_url = user.dwolla_id
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

        BankingMailer.account_added(user, funding_account).deliver_now
      rescue => e
        p e
        # Let user go through to the home screen but send email with error from dwolla
        # EMAIL: send user and error from Dwolla
        return
      end
    end

    private
    # recieve a total of all transations from each user
    def self.weekly_roundup
      begin
        # run roundups on Saturday
        day = Time.now

        # NOTE: Uncomment when setting automatic roundups
        # if day.saturday?
          # set last weeks date
          current_date = Date.today
          last_week_date = current_date - 1.week


          # loop through all CHECKING accounts connected with Milo
          Checking.all.each do |ck|
            # Find user based on checking.user_id
            user = User.find(ck.user_id)
            begin

              # find all transactions where transaction.account_id = ck.plaid_acct_id & pending = false OR transaction.user_id once it's added && within the last week
              transactions = Transaction
                .where(:account_id => ck.plaid_acct_id, :pending => false)
                .where("date > ?", last_week_date)
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
                withdraw_roundups(user, number_to_currency(roundup_total.round(2), unit:""), transactions.count, ck)
              end

              # send email to user with weekly data and how much they have in their account
            rescue
              # EMAIL: send us an email if a user's roundup task fails
            end
          end
          # NOTE: Uncomment when setting automatic roundups
        # end
      rescue ExceptionName
        # EMAIL: if all round up task breaks
        puts ExceptionName
      end
    end

    # add the users funding source, our account number, and the total roundup amount
    def self.withdraw_roundups(user, roundup_amount, total_transactions, funding_account)
      BankingMailer.transfer_start(user, roundup_amount, funding_account).deliver_now
      begin
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
            :value => roundup_amount
          },
          :metadata => {
            :user_id => user.id,
            :total_transactions => total_transactions
          }
        }

        transfer = TokenConcern.account_token.post "transfers", request_body
        current_transfer_url = transfer.headers[:location]

        # Get the status of the current transfer
        transfer_status = TokenConcern.account_token.get current_transfer_url
        current_transfer_status = transfer_status.status

        # Save transfer data
        Transfer.create_transfers(user, current_transfer_url, current_transfer_status, roundup_amount, total_transactions, "deposit")

        # add the roundup amount to the users balance
        User.add_account_balance(user, roundup_amount)

        puts "$#{roundup_amount}"

        # Email the user that the round up was successfully withdrawn
        BankingMailer.transfer_success(user, roundup_amount, funding_account).deliver_now
      rescue => e
        puts e
        # Email the user that there was an issue when withdrawing the round up
        BankingMailer.transfer_failed(user, roundup_amount, funding_account).deliver_now
      end

    end

    # TODO: create recurring fee for $1 tech fee
    # def self.monthly_tech_fee
    #   request_body
    # end

end
