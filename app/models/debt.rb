# == Schema Information
#
# Table name: debts
#
#  id              :integer          not null, primary key
#  account_name    :string
#  account_number  :string
#  debt_type       :string
#  begin_balance   :decimal(, )
#  current_balance :decimal(, )
#  minimum_payment :decimal(, )
#  credit_limit    :decimal(, )
#  apr             :decimal(, )
#  due_date        :date
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

# ================================================
# RUBY->MODEL->DEBT ==============================
# ================================================
class Debt < ActiveRecord::Base

  # ----------------------------------------------
  # RELATIONS ------------------------------------
  # ----------------------------------------------
  belongs_to :user

  # ----------------------------------------------
  # MONTHLY-INTEREST -----------------------------
  # ----------------------------------------------
  def monthly_interest
    monthly_interest = current_balance * apr / 36500 * 30
  end

  # ----------------------------------------------
  # PROGRESS-TO-ZERO -----------------------------
  # ----------------------------------------------
  # calculate the percentage until debt is paid off
  def progess_to_zero
    limit = credit_limit ? credit_limit : begin_balance
    inverse = limit - current_balance
    percentage = inverse / limit * 100
  end

  # ==============================================
  # DEBT-CURRENT-GOAL ============================
  # ==============================================

  # ----------------------------------------------
  # SUGGESTED-PAYMENT ----------------------------
  # ----------------------------------------------
  # the suggested payment on the current debt goal
  def suggested_payment(user_id)
    user = User.find_by_id(user_id)
    payment = user.extra_payment + minimum_payment
    # check to make sure the suggested payment isn't greater than the current balance
    payment = payment > current_balance ? current_balance : payment
  end

  # ----------------------------------------------
  # MONTHS-TO-ZERO -------------------------------
  # ----------------------------------------------
  # the number of months until the debt is paid off
  def months_to_zero(user_id)
    months = current_balance / suggested_payment(user_id)
    # round up to the nearest month
    months.ceil
  end

end
