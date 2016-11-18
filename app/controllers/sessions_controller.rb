# ================================================
# RUBY->CONTROLLER->SESSIONS-CONTROLLER ==========
# ================================================
class SessionsController < Devise::SessionsController

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
      # TODO: refresh transactions for the current week to show the user

      super
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
