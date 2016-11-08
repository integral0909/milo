desc "This task will calculate all users transactions for the past week and send an email"
# rake weekly_roundup
task :weekly_roundup => :environment do
  # for converting numbers to currency format
  include ActionView::Helpers::NumberHelper
  
  puts "Calculating transactions..."
  Dwolla.weekly_roundup
  puts "emails sent"
end
