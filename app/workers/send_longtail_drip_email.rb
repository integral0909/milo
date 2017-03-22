class SendLongtailDripEmail
  @queue = :send_longtail_drip_email_queue
  def self.perform(user_id, funding_account_id, drip_email_number)

    # return if Utility.env_disabled? :automated_emails
    # return if Utility.env_disabled? :automated_emails_influencer_drip

    user = User.find_by_id(user_id)
    funding_account = Account.find_by_plaid_acct_id(funding_account_id)

    if drip_email_number.present? && (1..4).include?(drip_email_number)
      LongtailDripMailer.send("longtail_drip_" + drip_email_number.to_s, user.id, funding_account.id).deliver_now
    end
  end
end
