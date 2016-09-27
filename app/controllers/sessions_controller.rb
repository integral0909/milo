class SessionsController < Devise::SessionsController
  after_action :prepare_intercom_shutdown, only: [:destroy]

  def new
    super
  end

  def create
    @user = User.find_by_email(params[:user][:email])
    if @user != nil
      super
    else
      # redirect to login page with error if login with wrong credentials
      redirect_to new_user_session_path, :flash => {:alert => "Invalid email or password"}
    end
  end

  protected

  def prepare_intercom_shutdown
    IntercomRails::ShutdownHelper.prepare_intercom_shutdown(session)
  end

end
