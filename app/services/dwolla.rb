require 'dwolla_swagger'

# All Dwolla functionality will be held here
module Dwolla

    # Create user on Dwolla
    def self.create_user(user)
      # We don't save name in 2 seperate fields so append -Milo to the name
      request_body = {
        :firstName => user.name,
        :lastName => '-Milo',
        :email => user.email
      }

      # Using DwollaSwagger - https://github.com/Dwolla/dwolla-swagger-ruby
      dwolla_customer_url = DwollaSwagger::CustomersApi.create(:body => request_body)
      puts "Adding dwolla url to user"
      ap dwolla_customer_url

      # Add dwolla customer URL to the user
      user = User.find(user.id)
      user.dwolla_id = dwolla_customer_url
      user.save!
    end

    # Add funding source for user to Dwolla
    def self.connect_funding_source(user)
      # Find the checking account associated with the user
      user_checking = Checking.where(user_id: user.id)
      # Get the info from the Account to add a funding source to Dwolla
      funding_account = Account.where(plaid_acct_id: user_checking.plaid_acct_id)

      customer_url = user.dwolla_id
      request_body = {
        routingNumber: funding_account.number,
        accountNumber: funding_account.account_number,
        type: funding_account.acct_subtype,
        name: funding_account.name
      }

      funding_source = DwollaSwagger::FundingsourcesApi.create_customer_funding_source(customer_url, :body => request_body)

      # Add the funding source to the user
      user = User.find(user.id)
      user.dwolla_funding_source = funding_source
      user.save!

    end
end
