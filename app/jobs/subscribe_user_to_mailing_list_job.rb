class SubscribeUserToMailingListJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    gibbon = Gibbon::Request.new
    gibbon.lists(ENV["MAILCHIMP_LIST_ID"]).members.create(body: { email_address: user.email, status: "subscribed", merge_fields: {FNAME: "#{user.first_name}", LNAME: "#{user.last_name}", ZIP: "#{user.zip}" }})
  end
end
