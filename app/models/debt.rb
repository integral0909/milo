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
  # NEXT-PAYMENT-DUE -----------------------------
  # ----------------------------------------------
  # is the next payment due this or next month?
  def next_payment_due
    day_due = due_date.strftime("%-d").to_i
    current = DateTime.now.to_date
    today = current.strftime("%-d").to_i
    month = current.strftime("%-m").to_i
    # Check to see if the due date is past today
    if day_due > today
      payment = current.change(day: day_due)
    else
      payment = current.change(month: month += 1, day: day_due)
    end
  end

  # ==============================================
  # INDIVIDUL-DEBT ===============================
  # ==============================================

  # ----------------------------------------------
  # MONTHS-TO-ZERO -------------------------------
  # ----------------------------------------------
  # the number of months until an individual debt is paid off
  def months_to_zero(user_id)
    months = current_balance / suggested_payment(user_id)
    # round up to the nearest month
    months.ceil
  end

  # ----------------------------------------------
  # PAYOFF-DATE ----------------------------------
  # ----------------------------------------------
  # the date an individual debt is paid off
  def payoff_date(user_id)
    month = next_payment_due.strftime("%-m").to_i + months_to_zero(user_id)
    payoff = next_payment_due.change(month: month)
  end

end
