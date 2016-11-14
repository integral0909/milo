desc "This task will calculate all users transactions for the past week and send an email"
# TODO: Add ability to run task for 1 user
# rake weekly_roundup
task :weekly_roundup => :environment do
  day = Time.now
  if day.saturday?
    # for converting numbers to currency format
    include ActionView::Helpers::NumberHelper

    puts "Starting Roundups..."
    Dwolla.weekly_roundup
    puts "-"*40
    puts "emails sent"
  end
end

desc "This task will pull in all users transactions for the past week"
# TODO: Add ability to run task for 1 user
# rake create_weekly_transactions
task :create_weekly_transactions => :environment do
  day = Time.now
  if day.saturday?
    puts "Pulling in last weeks transactions..."
    PlaidHelper.create_weekly_transactions
    puts "update complete"
  end
end
