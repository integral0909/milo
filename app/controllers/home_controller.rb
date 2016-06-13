class HomeController < ApplicationController

  def index
  end

  def accounts
    public_token = params[:public_token]
    # Exchange the Link public_token for a Plaid API access token
    exchange_token_response = Argyle.plaid_client.exchange_token(public_token)

    # Initialize a Plaid user
    @user = Argyle.plaid_client.set_user(exchange_token_response.access_token, ['connect'])

    # Retrieve information about the user's accounts
    # user.get('connect')

    # Transform each account object to a simple hash
    transformed_accounts = @user.accounts.map do |account|
      {
        balance: {
          available: account.available_balance,
          current: account.current_balance
        },
        meta: account.meta,
        type: account.type
      }
    end

    # transformed_transactions = user.transactions.map do |transaction|

    # end

    render :json => @user
    # Return the account data as a JSON response
    # content_type :json
    # { accounts: transformed_accounts }.to_json
  end

end
