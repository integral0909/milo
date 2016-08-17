class Contact < MailForm::Base
  attribute :name,      :validate => true
  attribute :email,     :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :message
  attribute :nickname,  :captcha  => true

  def headers
    {
      :subject => "Milo Contact Form",
      :to => "support@milosavings.com", # TODO :: change email recipient
      :from => %("#{name}" <#{email}>)
    }
  end
end
