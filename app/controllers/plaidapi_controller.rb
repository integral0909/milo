# ================================================
# RUBY->CONTROLLER->PLAIDAPI-CONTROLLER ==========
# ================================================
class PlaidapiController < ApplicationController

  # ----------------------------------------------
  # ADD-ACCOUNT ----------------------------------
  # ----------------------------------------------
  def add_account
    begin
      # NOTE: We are using v 1.7.1 for plaid-ruby: https://github.com/plaid/plaid-ruby/tree/v1.7.1
      #1 generate a public token for the user
      public_token = PublicToken.find_or_create_by(token: params[:public_token])

      #2 save public token to user's account
      save_public_token(public_token)

      #3 Exchange the Link public_token for a Plaid API access token
      exchange_token_response = Argyle.plaid_client.exchange_token(public_token.token)

      #4 add plaid access token for easy access when wanting to reconnect
      User.add_plaid_access_token(@user, exchange_token_response.access_token)

      #5 Initialize a Plaid user with connect then save the transactions
      auth_user = Argyle.plaid_client.set_user(@user.plaid_access_token, ['auth'])

      Transaction.create_accounts(auth_user.accounts, public_token, @user.id)

      auth_user.upgrade(:connect)

      #6 Set checking account
      accounts = Account.where(user_id: @user.id, acct_subtype: "checking")
      # IF, only one checking account connect automatically
      if accounts.size == 1
        Checking.create_checking(accounts)
        redirect_to signup_on_demand_path
      # ELSE, allow user to select
      else
        redirect_to new_checking_path
      end
    rescue => e
      # EMAIL: header=> Error while adding users account and transactions message=> @user was not able to add account through plaid. Error: e
      # puts e
      redirect_to user_accounts_path
    end
  end

  # ----------------------------------------------
  # UPDATE-ACCOUNTS ------------------------------
  # ----------------------------------------------
  def update_accounts
    @user = User.find(current_user.id)
    @user.public_tokens.each do |t|
      if exchange_token_response = Argyle.plaid_client.exchange_token(t.token)
        updated_response = HTTParty.post('https://tartan.plaid.com/connect/get', :body => {"client_id" => ENV["CLIENT_ID"], "secret" => ENV["SECRET"], "access_token" => exchange_token_response.access_token})
        user_obj = Hashie::Mash.new(updated_response)
        Transaction.update_accounts(user_obj.accounts, t, @user.id)
        #Transaction.update_transactions(user_obj.transactions, @user.id)
      end
    end
    redirect_to root_path
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # SAVE-PUBLIC-TOKEN -----------------------------
  # ----------------------------------------------
  def save_public_token(token)
    milo_current_user = User.find(current_user.id)
    milo_current_user.public_tokens << token
  end
end
