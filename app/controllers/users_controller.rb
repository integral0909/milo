# ================================================
# RUBY->CONTROLLER->USERS-CONTROLLER =============
# ================================================
class UsersController < ApplicationController
  before_action :authenticate_user!


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
      redirect_to root_path
    else
      flash[:alert] = @user.errors.full_messages.join(", ")
      redirect_to settings_security_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end
