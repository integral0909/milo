# ================================================
# RUBY->CONTROLLER->PLAIDAPI-CONTROLLER ==========
# ================================================
class PlaidapiController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :add_account


  # ----------------------------------------------
  # ADD-ACCOUNT ----------------------------------
  # ----------------------------------------------
  def add_account
    begin
      # REF: https://github.com/plaid/plaid-ruby
      #1 generate a public token for the user
      public_token = PublicToken.find_or_create_by(token: params[:public_token])

      #2 save public token to user's account
      save_public_token(public_token)

      #3 Exchange the Link public_token for a Plaid API access token
      exchange_token_response = Plaid::User.exchange_token(public_token.token)

      #4 add plaid access token for easy access when wanting to reconnect
      User.add_plaid_access_token(@user, exchange_token_response.access_token)

      #5 Load  Plaid user with connect product
      plaid_user = Plaid::User.load(:connect, @user.plaid_access_token)

      # Upgrade user to have auth product
      plaid_user.upgrade(:auth)

      Account.create_accounts(plaid_user.accounts, public_token, @user.id)

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
      flash.now[:error] =  "Looks like your account need a bit of help before being set up. We are on it!"
      redirect_to root_path
    end
  end

  # ----------------------------------------------
  # UPDATE-ACCOUNTS ------------------------------
  # ----------------------------------------------
  def update_accounts
    # @user = User.find(current_user.id)
    # @user.public_tokens.each do |t|
    #   if exchange_token_response = Argyle.plaid_client.exchange_token(t.token)
    #     updated_response = HTTParty.post('https://tartan.plaid.com/connect/get', :body => {"client_id" => ENV["CLIENT_ID"], "secret" => ENV["SECRET"], "access_token" => exchange_token_response.access_token})
    #     user_obj = Hashie::Mash.new(updated_response)
    #     Transaction.update_accounts(user_obj.accounts, t, @user.id)
    #     #Transaction.update_transactions(user_obj.transactions, @user.id)
    #   end
    # end
    # redirect_to root_path
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # SAVE-PUBLIC-TOKEN -----------------------------
  # ----------------------------------------------
  def save_public_token(token)
    milo_current_user = User.find(@user.id)
    milo_current_user.public_tokens << token
  end
end
