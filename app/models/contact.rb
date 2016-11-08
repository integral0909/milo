# ================================================
# RUBY->MODEL->CONTACT ===========================
# ================================================
class Contact < MailForm::Base

  # ----------------------------------------------
  # ATTRIBUTES -----------------------------------
  # ----------------------------------------------
  attribute :name,      :validate => true
  attribute :email,     :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :message
  attribute :nickname,  :captcha  => true

  # ----------------------------------------------
  # EMAIL-HEADERS --------------------------------
  # ----------------------------------------------
  def headers
    {
      :subject => "Milo Contact Form",
      :to => "support@milosavings.com", # TODO :: change email recipient
      :from => %("#{name}" <#{email}>)
    }
  end
end
