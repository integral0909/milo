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

        customer_url = user.dwolla_id
        request_body = {
          routingNumber: funding_account.bank_routing_number,
          accountNumber: funding_account.bank_account_number,
          type: funding_account.acct_subtype,
          name: funding_account.name
        }

        funding_source = TokenConcern.account_token.post "#{customer_url}/funding-sources", request_body

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

    # add the users funding source, our account number, and the total roundup ammount
    def self.withdraw_roundups(user, roundup_ammount)
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
          :user_id => user.id
        }
      }
      transfer = TokenConcern.account_token.post "transfers", request_body
      # Create Transaction object to save the data returned
      transfer.headers[:location]

    end

    # TODO: create recurring fee for $1 tech fee
    # def self.monthly_tech_fee
    #   request_body
    # end

end
