# ================================================
# RUBY->CONTROLLER->SESSIONS-CONTROLLER ==========
# ================================================
class SessionsController < Devise::SessionsController

  respond_to :json, :html

  # ----------------------------------------------
  # LAYOUT ---------------------------------------
  # ----------------------------------------------
  layout "signup"

  # ----------------------------------------------
  # FILTERS --------------------------------------
  # ----------------------------------------------
  after_action :prepare_intercom_shutdown, only: [:destroy]

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # NEW ------------------------------------------
  # ----------------------------------------------
  def new
    super
  end

  # ----------------------------------------------
  # CREATE ---------------------------------------
  # ----------------------------------------------
  def create
    @user = User.find_by_email(params[:user][:email])
    if @user != nil
      sign_out(:user) if current_user
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      # redirect to login page with error if login with wrong credentials
      redirect_to new_user_session_path, :flash => {:alert => "Invalid email or password"}
    end
  end

  # ==============================================
  # PROTECTED ====================================
  # ==============================================
  protected

  # ----------------------------------------------
  # PREPARE-INTERCOM-SHUTDOWN --------------------
  # ----------------------------------------------
  def prepare_intercom_shutdown
    IntercomRails::ShutdownHelper.prepare_intercom_shutdown(session)
  end

end
