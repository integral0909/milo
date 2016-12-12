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
      Dwolla.confirm_micro_deposits("0.#{params['deposit1']}", "0.#{params['deposit2']}", @user)

      # Find the checking account associated with the user
      user_checking = Checking.find_by_user_id(@user.id)
      # Get the info from the Account to add a funding source to Dwolla
      funding_account = Account.find_by_plaid_acct_id(user_checking.plaid_acct_id)
      BankingMailer.account_added(@user, funding_account)

      User.bank_verified(@user)
      flash[:success] = "Congrats! Your account is now verified!"
      redirect_to :back
    rescue => e
      flash[:alert] = "Looks the deposits did not match. Please try to verify again."
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

      redirect_to root_path
    else
      flash[:alert] = @account.errors.full_messages.join(", ")
      redirect_to :back
    end
  end

  # ----------------------------------------------
  # REMOVE ----------------------------------------
  # ----------------------------------------------
  def remove
    @accounts = Account.where(user_id: current_user.id)
    @accounts.destroy_all
    @checking = Checking.where(user_id: current_user.id)
    @checking.destroy_all
    Dwolla.remove_funding_source(@user)
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
