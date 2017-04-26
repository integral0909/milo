require 'resque'

class AddDwollaFundingSourceJob
  @queue = :dwolla_queue

  def self.perform(user_id)
    begin
      user = User.find(user_id)
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
      @dwolla_app_token = Dwolla.set_dwolla_token
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
end
