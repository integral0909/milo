class SettingsController < ApplicationController

  # ----------------------------------------------
  # FILTERS --------------------------------------
  # ----------------------------------------------
  before_action :authenticate_user!
  before_action :set_user

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # INDEX ----------------------------------------
  # ----------------------------------------------
  def index
    # Find the checking account associated with the user
    @checking = Checking.find_by(user_id: @user.id)
    # If, checking account exists get the account information
    if @checking
      @account = Account.find_by(plaid_acct_id: @checking.plaid_acct_id)
    end

  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # SET-USER -------------------------------------
  # ----------------------------------------------
  def set_user
    @user = User.find(current_user.id)
  end

end
