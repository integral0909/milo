class HomeController < ApplicationController

  before_action :authenticate_user!
  before_action :set_user

  def index
    # Find all accounts associated with the user
    @accounts = Account.where(user_id: @user.id)
    # Find the checking account associated with the user
    @checking = Checking.find_by(user_id: @user.id)
    # If, checking account exists get the transactions for that account
    if @checking
      @transactions = @user.transactions.where(account_id: @checking.plaid_acct_id)
    end
  end

  private

  def set_user
    @user = User.find(current_user.id)
  end

end
