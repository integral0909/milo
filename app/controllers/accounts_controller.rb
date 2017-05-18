# ================================================
# RUBY->CONTROLLER->ACCOUNTS-CONTROLLER ==========
# ================================================
class AccountsController < ApplicationController

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # INDEX ----------------------------------------
  # ----------------------------------------------
  def index
    render layout: "signup"
  end

  # ----------------------------------------------
  # NEW ------------------------------------------
  # ----------------------------------------------
  def new

    respond_to do |format|
      format.js
    end
  end

  # Account and Routing number form page on sign up process.
  def bank_verify
    # Find the checking account associated with the user
    @checking = Checking.find_by_user_id(@user.id)
    # Get the info from the Account to add account and routing number
    @account = Account.find_by_plaid_acct_id(@checking.plaid_acct_id)
    render layout: "signup"
    # set the account connected to the user
  end

  # form submittion to verify micro-deposits
  def verify_micro_deposits
    begin
      # Find the checking account associated with the user
      user_checking = Checking.find_by_user_id(@user.id)
      # Get the info from the Account to add a funding source to Dwolla
      funding_account = Account.find_by_plaid_acct_id(user_checking.plaid_acct_id)

      Dwolla.confirm_micro_deposits("0.#{params['deposit1']}", "0.#{params['deposit2']}", @user, funding_account)

      if funding_account.failed_verification_attempt && funding_account.failed_verification_attempt < 3
        flash[:alert] = "Looks like the deposits did not match. Only #{3 - funding_account.failed_verification_attempt} attempts left."
      elsif funding_account.failed_verification_attempt && funding_account.failed_verification_attempt >= 3
        Account.remove_accounts(@user)
        flash[:alert] = "You have exceeded the amount of tries to verify your account. Your banking account has been temporarily removed. Please reach out to dev@shiftsavings.com for assistance."
      else
        BankingMailer.account_added(@user, funding_account)
        flash[:success] = "Congrats! Your account is now verified!"
      end
      redirect_to :back
    rescue
      flash[:alert] = "Looks like there was an error when verifying your account. Please reach out to dev@shiftsavings for more help."

      redirect_to :back
    end
  end

  def update
    # set the account and routing numbers on the connected account
    @account = Account.find(params[:id])
    @account.update(account_params)
    if @account.save

      # send user to on_demand form after updating account with numbers
      if !@user.on_demand
        redirect_to signup_on_demand_path and return
      end

      redirect_to authenticated_root_path
    else
      flash[:alert] = @account.errors.full_messages.join(", ")
      redirect_to :back
    end
  end

  # ----------------------------------------------
  # REMOVE ----------------------------------------
  # ----------------------------------------------
  def remove
    pend_trans = Transfer.where(user_id: @user.id, status: "pending")

    if pend_trans.empty?
      p "::::::::::::NO PENDING TRANSACTIONS::::::::::"
      Account.remove_accounts(@user)
    else
      flash[:alert] = "Looks like there are still pending transactions on your account. Please wait for them to process before removing."

      redirect_to :back
    end

  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # ACCOUNT-PARAMS ----------------------------------
  # ----------------------------------------------
  def account_params
    params.require(:account).permit(:bank_account_number, :bank_routing_number)
  end

end
