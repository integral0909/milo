class PlaidapiController < ApplicationController

  def add_account
    #1 generate a public token for the user
    public_token = params[:public_token]

    #2 save public token to user's cashflow account
    # save_public_token(public_token) <<<UNCOMMENT ONCE USER MODEL IS BUILT>>>

    #3 Exchange the Link public_token for a Plaid API access token
    exchange_token_response = Argyle.plaid_client.exchange_token(public_token)

    #4 Initialize a Plaid user
    @plaid_user = Argyle.plaid_client.set_user(exchange_token_response.access_token, ['connect'])

    #5 pass data for parsing
    create_accounts(@plaid_user.accounts)
    # create_transactions(@plaid_user.transactions) <<<UNCOMMENT ONCE TRANSACTIONS MODEL IS BUILT>>>
  end

  private
  # def save_public_token(token)
  #   @user.public_tokens << token
  # end

  def create_accounts(plaid_user_accounts)
    plaid_user_accounts.each do |acct|
      account = Account.find_by(plaid_acct_id: acct.id)
      binding.pry
      if account
        account.update(
          account_name: acct.meta["name"],
          account_number: acct.meta["number"],
          available_balance: acct.available_balance,
          current_balance: acct.current_balance,
          institution_type: acct.institution_type,
          name: acct.name,
          numbers: acct.numbers,
          acct_subtype: acct.subtype,
          acct_type: acct.type
          )
      else
        Account.create(
          plaid_acct_id: acct.id,
          account_name: acct.meta["name"],
          account_number: acct.meta["number"],
          available_balance: acct.available_balance,
          current_balance: acct.current_balance,
          institution_type: acct.institution_type,
          name: acct.name,
          numbers: acct.numbers,
          acct_subtype: acct.subtype,
          acct_type: acct.type
          )
      end
    end
  end

  def create_transactions(plaid_user_transactions)

  end

end

    # # Transform each account object to a simple hash
    # transformed_accounts = @plaid_user.accounts.map do |account|
    #   {
    #     balance: {
    #       available: account.available_balance,
    #       current: account.current_balance
    #       },
    #       meta: account.meta,
    #       type: account.type
    #     }
    #   end

    # # transformed_transactions = @plaid_user.transactions.map do |transaction|

    # # end

    # render :json => @plaid_user
    # # Return the account data as a JSON response
    # # content_type :json
    # # { accounts: transformed_accounts }.to_json

# Retrieve information about the user's accounts -- Not clear on what this does
    # user.get('connect')
