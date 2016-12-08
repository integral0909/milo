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
  # REMOVE ----------------------------------------
  # ----------------------------------------------
  def remove
    @accounts = Account.where(user_id: current_user.id)
    @accounts.destroy_all
    @checking = Checking.where(user_id: current_user.id)
    @checking.destroy_all
    @user.dwolla_funding_source = nil
  end

end
