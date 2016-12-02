desc "This task will calculate all users transactions for the past week and send an email"
# TODO: Add ability to run task for 1 user
# For all users: rake weekly_roundup
# For specific user:  rake weekly_roundup['USER_ID']
task :weekly_roundup, [:user_id] => :environment do |t, args|
  day = Time.now
  current_date = Date.today
  # if the first round up of the month, count how many tech fees were collected
  current_date.day <= 7 ? @charge_tech_fee = true : @charge_tech_fee = false
  fees_charged = 0

  # if day.saturday?
    # for converting numbers to currency format
    include ActionView::Helpers::NumberHelper

    puts "Starting Roundups..."
    if !args.user_id.blank?
      # run weekly_roundup for the user
      user = User.find(args.user_id)

      # increase the fees collected by 1
      if !user.admin
        fees_charged += 1
      end

      ck  = Checking.find_by_user_id(user.id)
      Dwolla.weekly_roundup(user, ck)
    else
      Checking.all.each do |ck|
        user = User.find(ck.user_id)
        # increase the fees collected by 1
        if !user.admin
          fees_charged += 1
        end

        # run weekly_roundup for all users with checking accounts
        if user
          Dwolla.weekly_roundup(user, ck)
        end
      end

      # Only send the mailer if we collected tech fees
    end

    # send an email letting us know how much in fees were collected
    if fees_charged > 0
      BankingMailer.tech_fee_charged(fees_charged).deliver_now
    end

    puts "-"*40
    puts "emails sent"
  # end
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
