class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :public_tokens
  has_many :accounts
  has_many :transactions
  has_one  :checking

  validate :email_is_unique, on: :create
  validates_uniqueness_of :mobile_number
  validates :mobile_number, phone: { possible: false, allow_blank: true, types: [:mobile] }

  #filter_parameter_logging :verification_code

  private

  # Email should be unique
  def email_is_unique
    # Don't validate email if errors are already present
    return false unless self.errors[:email].empty?
    unless User.find_by_email(email).nil?
      errors.add(:email, "is already taken by another account")
    end
  end

  # Verify mobile number
  def needs_mobile_number_verifying?
    if is_verified
      return false
    end
    if mobile_number.empty?
      return false
    end
    return true
  end


end
