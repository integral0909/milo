module Contribution
  # Run the employer contribution for the current user
  #
  # @param [object] user current user
  # @param [integer] amount_in_cents current round up amount_in_cents
  def self.run_employer_contribution(user, amount_in_cents)
    @amount = amount_in_cents
    @user = user
    @employer = Business.find(@user.business_id)

    # check to make sure the max employer contribution (in cents) is less than already contributed to the employee. Also need to check pending contributions
    if Contribution.max_contribution_not_met
      # employer contribution amount
      @contribution_amount = Contribution.employer_contribution

      # add the pending_contribution to the user
      !@user.pending_contribution.nil? ? @user.pending_contribution += @contribution_amount : @user.pending_contribution = @contribution_amount

      # Check if the date coincides with the contribution frequency
      if Contribution.contribution_due?

        # add pending contribution to the users account_balance
        if !@user.account_balance.nil?
          @user.account_balance += @user.pending_contribution
        else
          @user.account_balance = @user.pending_contribution
        end
byebug
        # Add employer contribution amount to the user
        !@user.employer_contribution.nil? ? @user.employer_contribution += @user.pending_contribution : @user.employer_contribution = @user.pending_contribution

        Contribution.add_employer_contribution

        # reset pending contributions
        @user.pending_contribution = nil
      end
    end
  end

  # Increase contribution total to the business
  def self.add_employer_contribution
    byebug
    # add amount to current_contribution to pull when all round ups are finished
    !@employer.current_contribution.nil? ? @employer.current_contribution += @contribution_amount : @employer.current_contribution = @contribution_amount

    # add amount to total contribution
    !@employer.total_contribution.nil? ? @employer.total_contribution += @contribution_amount : @employer.total_contribution = @contribution_amount

    @employer.save!
  end

  # How much the employer contribution is for the current week
  def self.employer_contribution
    (@amount * @employer.match_percent/100).round(0)
  end

  # Check if the max contribution has been met by the employee
  def self.max_contribution_not_met
    @user.employer_contribution.nil? || @employer.max_contribution.nil? || ((@employer.max_contribution * 100) >= @user.employer_contribution)
  end

  # Check if the employer contribution is due on the current round up week
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
        # If frequency not set, then run add contributions
        true
    end
  end
end
