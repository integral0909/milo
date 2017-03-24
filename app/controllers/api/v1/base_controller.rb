# ================================================
# RUBY->API->V1->BASE-CONTROLLER =================
# ================================================
class Api::V1::BaseController < ApplicationController

  # ----------------------------------------------
  # CONCERNS -------------------------------------
  # ----------------------------------------------
  include Authenticable

  # ----------------------------------------------
  # ----------------------------------------------
  # ----------------------------------------------
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

end
