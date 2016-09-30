desc "This task will calculate all users transactions for the past week and send an email"
# rake weekly_roundup
task :weekly_roundup => :environment do
  puts "Calculating transactions..."
  Dwolla.weekly_roundup
  puts "emails sent"
end

# task :send_reminders => :environment do
#   User.send_reminders
# end
