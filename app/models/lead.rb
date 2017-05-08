class Lead < MailForm::Base
  attribute :company,                   :validate => true
  attribute :company_contact_name,      :validate => true
  attribute :company_contact_email,     :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :lead_name,                 :validate => true
  attribute :lead_email,                :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :message
  attribute :nickname,  :captcha  => true

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      :subject => "New Lead :: Shift Works",
      :to => "admin@shiftsavings.com",
      :from => %("#{lead_name}" <#{lead_email}>)
    }
  end
  
end
