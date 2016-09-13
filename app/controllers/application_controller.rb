class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper ApplicationHelper
  before_filter :set_user


  private
# pull the referral id from the params if the user is signing up from a referral url
  def capture_referal
    if !session[:referral]
      session[:referral] = params[:referral] if params[:referral]
    end
  end
# The following variables need to set in order of function call
  def set_user
    @user = User.find(current_user.id) if current_user
    set_accounts_and_checking
  end

  def set_accounts_and_checking
    # Find all accounts associated with the user
    if @user
      @accounts = Account.where(user_id: @user.id)
      # Find all checking accounts associated withe the user
      @checking = Checking.find_by(user_id: @user.id)
      set_transactions
    end
  end

  def set_transactions
    # If, checking account exists get the transactions for that account
    @transactions = Transaction.where(account_id: @checking.plaid_acct_id) if @checking
  end

end
