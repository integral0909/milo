class PlaidapiController < ApplicationController

  before_action :authenticate_user!

  def add_account
    #1 generate a public token for the user
    public_token = PublicToken.create(token: params[:public_token])

    #2 save public token to user's milo account
    save_public_token(public_token)

    #3 Exchange the Link public_token for a Plaid API access token
    exchange_token_response = Argyle.plaid_client.exchange_token(public_token.token)

    #4 Initialize a Plaid user
    @plaid_user = Argyle.plaid_client.set_user(exchange_token_response.access_token, ['connect'])

    @user = User.find(current_user.id)
    Transaction.create_accounts(@plaid_user.accounts, public_token, @user.id)
    Transaction.create_transactions(@plaid_user.transactions)
    redirect_to root_path
  end

  private

  def save_public_token(token)
    milo_current_user = User.find_by(id: current_user.id)
    milo_current_user.public_tokens << token
  end

end
