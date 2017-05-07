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
    # If business owner
    if @biz_owner
      # Show the latest 4 transfers
      @transfers = Transfer.where(user_id: @user.id).order(date: :desc).limit(4)
      # Total Contributions
      @total_contrib = number_to_currency(@biz.total_contribution / 100.00, unit:"") if @biz.total_contribution
      # Total Employees
      @total_employees = User.where(business_id: @biz.id).count - 1
    else
      subheader_set_nil
    end
  end

  # ----------------------------------------------
  # HISTORY --------------------------------------
  # ----------------------------------------------
  def history
    @transfers = Transfer.where(user_id: @user.id).order(date: :desc).all
    @transfer_months = @transfers.group_by { |t| t.date.to_date.beginning_of_month }
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
