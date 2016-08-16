class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :capture_referal


  private
# pull the referral id from the params if the user is signing up from a referral url
  def capture_referal
    session[:referral] = params[:referral] if params[:referral]
  end

end
