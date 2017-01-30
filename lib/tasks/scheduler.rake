desc "This task will calculate all users transactions for the past week and send an email"
# TODO: Add ability to run task for 1 user
# For all users: rake weekly_roundup
# For specific user:  rake weekly_roundup['USER_ID']
task :weekly_roundup, [:user_id] => :environment do |t, args|
  day = Time.now
  current_date = Date.today
  # if the first round up of the month, count how many tech fees were collected
  current_date.day <= 7 ? @charge_tech_fee = true : @charge_tech_fee = false

    # for converting numbers to currency format
    include ActionView::Helpers::NumberHelper

    if !args.user_id.blank?
      # run weekly_roundup for the user
      user = User.find(args.user_id)
      puts "Starting Roundups for #{user.email}"

      ck  = Checking.find_by_user_id(user.id)
      Dwolla.weekly_roundup(user, ck)

      if @charge_tech_fee && !user.admin
        # send an email letting us know how much in fees were collected
        BankingMailer.tech_fee_charged("1").deliver_now
      end
      puts "-"*40
      puts "email sent"
    else
      if day.saturday?
        puts "Starting Roundups for all users"
        Checking.all.each do |ck|
          user = User.find(ck.user_id)

          # run weekly_roundup for all users with checking accounts that are verified
          if user && !user.pause_savings && !user.bank_not_verified
            Dwolla.weekly_roundup(user, ck)
          end

        end

        if @charge_tech_fee
          # send an email letting us know how much in fees were collected
          fee_transfers = Transfer.where(tech_fee_charged: true, date: current_date).count
          admin_count = User.where(admin: true).count
          BankingMailer.tech_fee_charged(fee_transfers - admin_count).deliver_now
        end

        puts "-"*40
        puts "emails sent"
      end
    end
end

desc "This task will pull in all users transactions for the past week"
# For all users: rake create_weekly_transactions
# For specific user:  rake create_weekly_transactions['USER_ID']
task :create_weekly_transactions, [:user_id] => :environment do |t, args|
  day = Time.now

    if !args.user_id.blank?
      # run weekly_roundup for the user
      user = User.find(args.user_id)
      puts "Pulling in last weeks transactions for #{user.email}"
      ck  = Checking.find_by_user_id(user.id)
      PlaidHelper.create_weekly_transactions(user, ck)
      puts "-"*40
      puts "update completed for #{user.email}"
    else
      if day.saturday?
        Checking.all.each do |ck|
          user = User.find(ck.user_id)
          # run create_weekly_transactions for all users with checking accounts
          if user && !user.bank_not_verified
            PlaidHelper.create_weekly_transactions(user, ck)
          end
        end
        puts "-"*40
        puts "update complete"
      end
    end

end
