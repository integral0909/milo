# ================================================
# RUBY->API->V1->USERS-CONTROLLER ================
# ================================================
class Api::V1::UsersController < Api::V1::BaseController

  respond_to :json

  # ----------------------------------------------
  # FILTERS --------------------------------------
  # ----------------------------------------------
  before_action :authenticate_with_token!, only: [:update, :destroy]

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # SHOW -----------------------------------------
  # ----------------------------------------------
  def show
    user = User.find(params[:id])

    user_json = user.as_json(
      :only => [:id, :email, :name, :created_at, :invite_code],
      :methods => [:avatar_url])

    render json: {
      "user": user_json
    }
  end

  # ----------------------------------------------
  # CREATE ---------------------------------------
  # ----------------------------------------------
  def create
    user = User.new(user_params)
    if user.save
      render json: { id: user.id, email: user.email, name: user.name, auth_token: user.auth_token }, status: 201, location: [:api, :v1, user]
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  # ----------------------------------------------
  # UPDATE ---------------------------------------
  # ----------------------------------------------
  def update
    user = current_user
    if user.update(user_params)
      render json: user.as_json( :methods => [:avatar_url] ), status: 200, location: [:api, user]
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  # ----------------------------------------------
  # DESTROY --------------------------------------
  # ----------------------------------------------
  def destroy
    current_user.destroy
    head 204
  end

  # ----------------------------------------------
  # FORGOT-PASSWORD ------------------------------
  # ----------------------------------------------
  def forgot_password
    if params[:email].present? && user = User.find_by(email: params[:email])
      user.send_reset_password_instructions
      render json: { message: "We sent you a password reset email" }, status: 200
    else
      render json: { errors: "We were unable to find a user with that email address" }, status: 422
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
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :avatar, :zip)
  end

end
