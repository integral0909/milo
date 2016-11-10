class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper ApplicationHelper
  before_filter :set_user, :capture_referral

  private

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  # pull the referral id from the params if the user is signing up from a referral url
  def capture_referral
    if !session[:referral]
      session[:referral] = params[:referral] if params[:referral]
    end
  end

  # The following variables need to set in order of function call
  def set_user
    @user = User.find(current_user.id) if current_user
    set_accounts_and_checking
  end

  def set_accounts_and_checking
    # Find all accounts associated with the user
    if @user
      @accounts = Account.where(user_id: @user.id)
      # Find all checking accounts associated withe the user
      @checking = Checking.find_by(user_id: @user.id)
      set_dwolla_id
    end
  end

  # Add Dwolla id to user if not already set NOTE: Depricate once all waitlist users sign up
  def set_dwolla_id
    if !@user.dwolla_id
      Dwolla.create_user(@user)
    end
  end

end
