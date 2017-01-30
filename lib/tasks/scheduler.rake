desc "This task will calculate all users transactions for the past week and send an email"
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

        # check if the checking account is associated with a business
        biz_owner = biz_account(user)

        # run weekly_roundup for all users with checking accounts
        if user && biz_owner.nil? && !user.pause_savings && !user.bank_not_verified
          puts "pulled roundups for #{user.email}"

        # run weekly_roundup for all users with checking accounts that are verified
          Dwolla.weekly_roundup(user, ck)
        end

        if @charge_tech_fee
          # send an email letting us know how much in fees were collected
          fee_transfers = Transfer.where(tech_fee_charged: true, date: current_date).count
          admin_count = User.where(admin: true).count
          BankingMailer.tech_fee_charged(fee_transfers - admin_count).deliver_now
        end
      end
      # Withdraw the current contribution per employer
      Dwolla.withdraw_employer_contribution

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

        # check if the checking account is associated with a business
        biz_owner = biz_account(user)

        # run create_weekly_transactions for all users with checking accounts
        if user && biz_owner.nil? && !user.bank_not_verified
          puts "pulling transactions for #{user.email}"

          PlaidHelper.create_weekly_transactions(user, ck)
        end
      end
      puts "-"*40
      puts "update complete"
    end
  end
end

desc "This task will charge businesses the monthly tech fee"
# For all users: rake charge_biz_tech_fee
# For specific user:  rake charge_biz_tech_fee['BUSINESS_ID']
task :charge_biz_tech_fee, [:biz_id] => :environment do |t, args|
  current_date = Date.today
  # if the first round up of the month, count how many tech fees were collected
  day = Time.now

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
    if day.saturday? && (current_date.day <= 7)
      Business.all.each do |biz|
        user = User.find(biz.owner)
        ck = Checking.find_by_user_id(user.id)
        # run create_weekly_transactions for all users with checking accounts
        if user && ck
          Dwolla.charge_biz_tech_fee(biz, user, ck)
        end
      end
      puts "-"*40
      puts "Charge complete"
    end
  end
end

def biz_account(user)
  Business.find_by_owner(user.id)
end
