class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :public_tokens
  has_many :accounts
  has_many :transactions
  has_one  :checking
  after_create :send_admin_mail


  def send_admin_mail
    UserMailer.send_new_user_message(self).deliver
  end

  validate :email_is_unique, on: :create

  private
  # email should be unique
   def email_is_unique
    #  dont validate email if errors are already present
     return false unless self.errors[:email].empty?
     unless User.find_by_email(email).nil?
       errors.add(:email, "is already taken by another account")
     end
   end


end
