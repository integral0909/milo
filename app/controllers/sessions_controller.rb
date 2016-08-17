class SessionsController < Devise::SessionsController

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

end
