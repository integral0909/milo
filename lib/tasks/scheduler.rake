desc "This task will calculate all users transactions for the past week and send an email"
# TODO: Add ability to run task for 1 user
# For all users: rake weekly_roundup
# For specific user:  rake weekly_roundup['USER_ID']
task :weekly_roundup, [:user_id] => :environment do |t, args|
  day = Time.now

  # if day.saturday?
    # for converting numbers to currency format
    include ActionView::Helpers::NumberHelper

    puts "Starting Roundups..."
    if !args.user_id.blank?
      # run weekly_roundup for the user
      user = User.find(args.user_id)
      ck  = Checking.find_by_user_id(user.id)
      Dwolla.weekly_roundup(user, ck)
    else
      Checking.all.each do |ck|
        user = User.find(ck.user_id)
        # run weekly_roundup for all users with checking accounts
        Dwolla.weekly_roundup(user, ck)
      end
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
        PlaidHelper.create_weekly_transactions(user, ck)
      end
    end

    puts "-"*40
    puts "update complete"
  end
end
