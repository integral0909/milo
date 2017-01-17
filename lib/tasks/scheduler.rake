desc "This task will calculate all users transactions for the past week and send an email"
# For all users: rake weekly_roundup
# For specific user:  rake weekly_roundup['USER_ID']
task :weekly_roundup, [:user_id] => :environment do |t, args|
  day = Time.now
  current_date = Date.today
  # if the first round up of the month, count how many tech fees were collected
  current_date.day <= 7 ? @charge_tech_fee = true : @charge_tech_fee = false

  if day.saturday?
    # for converting numbers to currency format
    include ActionView::Helpers::NumberHelper

    puts "Starting Roundups..."
    if !args.user_id.blank?
      # run weekly_roundup for the user
      user = User.find(args.user_id)

      ck  = Checking.find_by_user_id(user.id)
      Dwolla.weekly_roundup(user, ck)

      if @charge_tech_fee && !user.admin
        # send an email letting us know how much in fees were collected
        BankingMailer.tech_fee_charged("1").deliver_now
      end
    else
      Checking.all.each do |ck|
        user = User.find(ck.user_id)

        # run weekly_roundup for all users with checking accounts
        if user
          Dwolla.weekly_roundup(user, ck)
        end

      end

      if @charge_tech_fee
        # send an email letting us know how much in fees were collected
        fee_transfers = Transfer.where(tech_fee_charged: true, date: current_date).count
        admin_count = User.where(admin: true).count
        BankingMailer.tech_fee_charged(fee_transfers - admin_count).deliver_now
      end

      # Withdraw the total
      Dwolla.withdraw_employer_contribution

    end

    puts "-"*40
    puts "emails sent"
  end
end

desc "This task will pull in all users transactions for the past week"
# For all users: rake create_weekly_transactions
# For specific user:  rake create_weekly_transactions['USER_ID']
task :create_weekly_transactions, [:user_id] => :environment do |t, args|
  day = Time.now

  if day.saturday?
    puts "Pulling in last weeks transactions..."
    if !args.user_id.blank?
      # run weekly_roundup for the user
      user = User.find(args.user_id)
      ck  = Checking.find_by_user_id(user.id)
      PlaidHelper.create_weekly_transactions(user, ck)
    else
      Checking.all.each do |ck|
        user = User.find(ck.user_id)
        # run create_weekly_transactions for all users with checking accounts
        if user
          PlaidHelper.create_weekly_transactions(user, ck)
        end
      end
    end

    puts "-"*40
    puts "update complete"
  end
end

desc "This task will charge businesses the monthly tech fee"
# For all users: rake charge_biz_tech_fee
# For specific user:  rake charge_biz_tech_fee['BUSINESS_ID']
task :charge_biz_tech_fee, [:biz_id] => :environment do |t, args|
  current_date = Date.today
  # if the first round up of the month, count how many tech fees were collected
  day = Time.now

  # if day.saturday? && (current_date.day <= 7)
    include ActionView::Helpers::NumberHelper

    puts "Charging monthly fee for businesses..."
    if !args.biz_id.blank?
      # run weekly_roundup for the user
      biz = Business.find(args.biz_id)
      user = User.find(biz.owner)
      ck = Checking.find_by_user_id(user.id)
      # Charge biz tech fee for all linked employees
      Dwolla.charge_biz_tech_fee(biz, user, ck)
    else
      Business.all.each do |biz|
        user = User.find(biz.owner)
        ck = Checking.find_by_user_id(user.id)
        # run create_weekly_transactions for all users with checking accounts
        if user && ck
          Dwolla.charge_biz_tech_fee(biz, user, ck)
        end
      end
    end

    puts "-"*40
    puts "Charge complete"
  # end
end
