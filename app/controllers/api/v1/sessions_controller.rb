# ================================================
# RUBY->API->V1->SESSIONS-CONTROLLER =============
# ================================================
class Api::V1::SessionsController < Api::V1::BaseController

  respond_to :json

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # CREATE ---------------------------------------
  # ----------------------------------------------
  def create
	  user_password = params["session"]["session[password]"]
	  user_email	= params["session"]["session[email]"].presence
	  user = user_email && User.find_by(email: user_email)

	  if user && user.valid_password?(user_password)
	  	sign_in user, store: false
	  	user.generate_authentication_token!
	  	user.save
	  	render json: { auth_token: user.auth_token, id: user.id, email: user.email, name: user.name, avatar_url: user.avatar_url }, status: 200, location: [:api, user]
	  else
	  	render json: { errors: "Invalid email or password" }, status: 422
	  end
	end

  # ----------------------------------------------
  # DESTROY --------------------------------------
  # ----------------------------------------------
  def destroy
	  user = User.find_by(auth_token: params[:id])
	  if user
			user.generate_authentication_token!
			user.save
			render json: { auth_token: user.auth_token, id: user.id, email: user.email, name: user.name, avatar_url: user.avatar_url }, status: 200, location: [:api, user]
	  else
	  	render json: { errors: "Expired authentication token" }, status: 422
	  end
	end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # CREATE-PARAMS --------------------------------
  # ----------------------------------------------
  def create_params
    params.require(:user).permit(:email, :password)
  end

end
