class WorksController < ApplicationController

  # ----------------------------------------------
  # CONCERNS -------------------------------------
  # ----------------------------------------------
  include ActionView::Helpers::NumberHelper
  include SubheaderHelper

  # ----------------------------------------------
  # FILTERS --------------------------------------
  # ----------------------------------------------
  before_action :authenticate_user!
  before_action :set_subheader
  before_action :set_user

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # INDEX ----------------------------------------
  # ----------------------------------------------
  def index
    # Show the latest 4 transfers
    @transfers = Transfer.where(user_id: @user.id).order(date: :desc).limit(4)
    
    @total_contrib = number_to_currency(@biz.total_contribution / 100.00, unit:"") if @biz.total_contribution
    @total_employees = User.where(business_id: @biz.id).count - 1
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # SET-SUBHEADER --------------------------------
  # ----------------------------------------------
  def set_subheader
    subheader_set :works
  end

end
