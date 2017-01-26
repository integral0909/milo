module Contribution
  def run_employer_contribution(user, amount_in_cents)
    @employer = Business.find(user.business_id)

    # check to make sure the max employer contribution (in cents) is less than already contributed to the employee. Also need to check pending contributions
    if Contribution.max_contribution_not_met
      # employer contribution amount
      contribution_amount = (amount_in_cents * @employer.match_percent/100).round(0)

      # add the pending_contribution to the user
      !user.pending_contribution.nil? ? user.pending_contribution += contribution_amount : user.pending_contribution = contribution_amount

      # Check if the date coincides with the contribution frequency
      if Contribution.contribution_due?

        total_amount = amount_in_cents + user.pending_contribution

        if !user.account_balance.nil?
          user.account_balance += total_amount
        else
          user.account_balance = total_amount
        end

        # Add employer contribution amount to the user
        !user.employer_contribution.nil? ? user.employer_contribution += (amount.to_f * 100).round(0) : user.employer_contribution = (amount.to_f * 100).round(0)

        # reset pending contributions
        user.pending_contribution = nil
      end
    end
  end


  # Increase contribution total to the business
  #
  # @param [object] user current user
  # @param [integer] amount amount to increase in cents
  def self.add_employer_contribution(user, amount)
    biz = Business.find(user.business_id)

    # add amount to current_contribution to pull when all round ups are finished
    !biz.current_contribution.nil? ? biz.current_contribution += (amount.to_f * 100).round(0) : biz.current_contribution = (amount.to_f * 100).round(0)

    # add amount to total contribution
    !biz.total_contribution.nil? ? biz.total_contribution += (amount.to_f * 100).round(0) : biz.total_contribution = (amount.to_f * 100).round(0)

    biz.save!
  end

  def self.max_contribution_not_met
    @employer.max_contribution && ((@employer.max_contribution * 100) >= user.employer_contribution)
  end

  def self.contribution_due?
    case @employer.frequency
      when 'Weekly'
        # Will always run
        true
      when 'Bi-Monthly'
        # Check if the week is the 1st or 3rd weekend.
         Date.today.week_of_month == 1 || Date.today.week_of_month == 3
      when 'Monthly'
        # Check if it's the first week of the month
        Date.today.first_week?
      when 'Quarterly'
        (Date.today.month == 1 || Date.today.month == 4 || Date.today.month == 7 || Date.today.month == 10) && Date.today.first_week?
      when 'Yearly'
        # Check if current date is past the Employers sign up date (NOTE: change to match frequency_set_date once implemented)
        Date.today.next_year <= @employer.created_at
      else
        # don't run contribution if frequency setting breaks
        false
    end
  end
end
