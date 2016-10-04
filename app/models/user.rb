class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :public_tokens
  has_many :accounts
  has_many :transactions
  has_one  :checking

  attr_accessor :current_step

  validate :email_is_unique, on: :create
  validate :password_strength

  validates :mobile_number, phone: { possible: false, allow_blank: true, types: [:mobile] }, if: -> { current_step?(:phone_verify) }

  #filter_parameter_logging :verification_code

  # Phone Verification
  def needs_mobile_number_verifying?
    if is_verified
      return false
    end
    if mobile_number.blank?
      return false
    end
    return true
  end

  # Current Step
  def current_step?(step_key)
    current_step.blank? || current_step == step_key
  end

  private

  # Email should be unique
  def email_is_unique
    # Don't validate email if errors are already present
    return false unless self.errors[:email].empty?
    unless User.find_by_email(email).nil?
      errors.add(:email, "is already taken by another account")
    end
  end

  # Strong password
  def password_strength
    if password.present? and not password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)./)
      errors.add :password, "must include at least one lowercase letter, one uppercase letter, and one number."
    end
  end

end
