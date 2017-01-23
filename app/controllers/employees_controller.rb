# ================================================
# RUBY->CONTROLLER->EMPLOYEES-CONTROLLER =========
# ================================================
class EmployeesController < ApplicationController
  include ActionView::Helpers::NumberHelper

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # INDEX ----------------------------------------
  # ----------------------------------------------
  def index
    @employees = User.where(business_id: current_user.business_id).all.order(id: :desc)

    set_employee_data
  end

  # ----------------------------------------------
  # DESTROY --------------------------------------
  # ----------------------------------------------
  def destroy
    @employee = User.find(params[:id])
    @employee.business_id = nil
    # skip validations incase there is an issue on the user object (ex: they haven't fully signed up)
    @employee.save(validate: false)

    respond_to do |format|
      format.js
    end
  end

  private

  def set_employee_data
    @emp_data = []
    @employees.each do |e|
      emp = {}
      emp['name'] = e.name
      emp['email'] = e.email
      emp['id'] = e.id
      emp['total_contrib'] = set_total_contribution(e)

      transfers = Transfer.where(user_id: e.id)
      if !transfers.empty?
        emp['last_contrib'] = transfers.last.roundup_amount
      end
      @emp_data << emp
    end
  end


  # ----------------------------------------------
  # SET-TRANSFER-AVERAGE -------------------------
  # ----------------------------------------------
  # transfers: All the transfers associated with the user
  # return: The average transfer amount
  def set_transfer_average(transfers)
    all_transfer_amounts = transfers.map {|tr| tr.roundup_amount.to_f }
    all_transfer_average = (all_transfer_amounts.inject{ |sum, el| sum + el }.to_f / all_transfer_amounts.size)
    @transfer_avg = (all_transfer_average > 0) ? number_to_currency(all_transfer_average) : "$0.00"
  end

  def set_total_contribution(e)
    if e.employer_contribution
      return number_to_currency((e.employer_contribution / 100))
    end
  end

end
