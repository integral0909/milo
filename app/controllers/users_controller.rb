# ================================================
# RUBY->CONTROLLER->USERS-CONTROLLER =============
# ================================================
class UsersController < ApplicationController
  before_action :authenticate_user!

  # for changing input string to currency
  include ActionView::Helpers::NumberHelper

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # SHOW -----------------------------------------
  # ----------------------------------------------
  def show
    @user = User.find(params[:id])
    @goals = @user.goals
  end

  # ----------------------------------------------
  # UPDATE-PASSWORD ------------------------------
  # Allowing the user to update the password from the dashboard
  # ----------------------------------------------
  def update_password
    @user = User.find(current_user.id)
    if @user.update(user_params)
      # Sign in the user by passing validation in case their password changed
      bypass_sign_in(@user)
      flash[:notice] = "Password Updated"
      redirect_to authenticated_root_path
    else
      flash[:alert] = @user.errors.full_messages.join(", ")
      redirect_to settings_security_path
    end
  end

  def withdraw_funds
    # convert amount requested to cents
    @withdraw_amount = (params[:user][:requested_amount].to_f * 100).round(0)
    # Check if user has the amount requested_amount
    if @withdraw_amount <= @user.account_balance
      begin

        if Dwolla.last_transfer_processed(@user)
          # initiate transfer of funds to user
          Dwolla.send_funds_to_user(@user, number_to_currency(params[:user][:requested_amount], unit:""))

          flash[:success] = "Your savings are on the way!"
        else
          flash[:alert] = "It looks like a transaction is still processing. Please wait until it is processed before withdrawing your funds."
        end
        redirect_to authenticated_root_path
      rescue => e
        flash[:alert] = e
        redirect_to :back
      end
    else
      flash[:alert] = "The amount requested was more than your account balance."
      redirect_to :back
    end
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # USER-PARAMS ----------------------------------
  # ----------------------------------------------
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end
