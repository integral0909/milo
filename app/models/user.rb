# == Schema Information
#
# Table name: users
#
#  id                               :integer          not null, primary key
#  email                            :string(255)      default(""), not null
#  encrypted_password               :string(255)      default(""), not null
#  reset_password_token             :string(255)
#  reset_password_sent_at           :datetime
#  remember_created_at              :datetime
#  sign_in_count                    :integer          default(0), not null
#  current_sign_in_at               :datetime
#  last_sign_in_at                  :datetime
#  current_sign_in_ip               :inet
#  last_sign_in_ip                  :inet
#  invited                          :boolean
#  admin                            :boolean
#  referral_code                    :string
#  name                             :string
#  zip                              :string
#  mobile_number                    :string
#  verification_code                :string
#  is_verified                      :boolean
#  dwolla_id                        :string
#  dwolla_funding_source            :string
#  on_demand                        :boolean
#  agreement                        :boolean
#  address                          :string
#  city                             :string
#  state                            :string
#  avater                           :attachment
#  account_balance                  :integer
#  long_tail                        :boolean
#  bank_not_verified                :boolean
#  employer_contribution            :integer
#  pending_contribution             :integer
#

# ================================================
# RUBY->MODEL->USER ==============================
# ================================================
class User < ActiveRecord::Base
  attr_accessor :requested_amount

  # ----------------------------------------------
  # DEVISE ---------------------------------------
  # ----------------------------------------------
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable, :timeoutable, :lockable

  # ----------------------------------------------
  # RELATIONS ------------------------------------
  # ----------------------------------------------
  belongs_to :business

  has_one  :checking

  has_many :accounts
  has_many :goals, dependent: :destroy
  has_many :public_tokens
  has_many :transactions

  # ----------------------------------------------
  # CALLBACKS ------------------------------------
  # ----------------------------------------------
  #before_create :generate_authentication_token

  # ----------------------------------------------
  # NESTED-ATTRIBUTES ----------------------------
  # ----------------------------------------------
  accepts_nested_attributes_for :business

  # ----------------------------------------------
  # VALIDATIONS ----------------------------------
  # ----------------------------------------------
  validates :name, presence: true
  validates :zip, presence: true
  validates :email, presence: true, length: { maximum: 255 },
              format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i },
              uniqueness: { case_sensitive: false }
  validate :password_strength

  # validate :mobile_number_is_unique, on: :update
  validates :mobile_number, phone: { possible: false, allow_blank: true, types: [:mobile] }

  # ----------------------------------------------
  # AVATAR ---------------------------------------
  # ----------------------------------------------
  has_attached_file :avatar, styles: { large: "512x512", medium: "300x300", thumb: "100x100" }
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  # ----------------------------------------------
  # MOBILE-NUMBER-VERIFY -------------------------
  # ----------------------------------------------
  # Does the user account need to be verified?
  def needs_mobile_number_verifying?
    if is_verified
      return false
    end
    if mobile_number.blank?
      return false
    end
    return true
  end

  # ----------------------------------------------
  # PLAID-ACCESS-TOKEN ---------------------------
  # ----------------------------------------------
  # Saving the plaid access token to the user model
  def self.add_plaid_access_token(user, access_token)
    user.plaid_access_token = access_token
    user.save!
  end

  # ----------------------------------------------
  # ADD-BALANCE ----------------------------------
  # ----------------------------------------------
  # Add round up amount to the users account balance
  def self.add_account_balance(user, amount)
    # roundup amount converted to cents
    amount_in_cents = (amount.to_f * 100).round(0)

    # Add current roundups
    self.add_roundup(user, amount_in_cents)

    # Check if the user is associated with a business
    if !user.business_id.nil?
      Contribution.run_employer_contribution(user, amount_in_cents)
    end

    user.save!
  end

  # ----------------------------------------------
  # DECREASE-BALANCE -----------------------------
  # ----------------------------------------------
  # Decrease withdrawn amount from the users account balance
  def self.decrease_account_balance(user, amount)
    user.account_balance -= (amount.to_f * 100).round(0)
    user.save!
  end

  # ----------------------------------------------
  # LONG-TAIL-ACCOUNT ----------------------------
  # ----------------------------------------------
  # Set user as long-tail user
  def self.add_long_tail(user)
    user.bank_not_verified = true
    user.long_tail = true
    user.save!
  end

  # ----------------------------------------------
  # LONG-TAIL-ACCOUNT ----------------------------
  # ----------------------------------------------
  # Set user as long-tail user
  def self.bank_verified(user)
    user.bank_not_verified = false
    user.save!
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  def self.add_roundup(user, amount)
    !user.account_balance.nil? ? user.account_balance += amount : user.account_balance = amount
  end

  # ----------------------------------------------
  # EMAIL-UNIQUE ---------------------------------
  # ----------------------------------------------
  def email_is_unique
    # Don't validate email if errors are already present
    return false unless self.errors[:email].empty?
    unless User.find_by_email(email).nil?
      errors.add(:email, "is already taken by another account")
    end
  end

  # ----------------------------------------------
  # STRONG-PASSWORD ------------------------------
  # ----------------------------------------------
  def password_strength
    if password.present? and not password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)./)
      errors.add :password, "must include at least one lowercase letter, one uppercase letter, and one number."
    end
  end

  # ----------------------------------------------
  # GENERATE-AUTHENTICATION-TOKEN ----------------
  # ----------------------------------------------
  # def generate_authentication_token
  #   loop do
  #     self.authentication_token = SecureRandom.base64(64)
  #     break unless User.find_by(authentication_token: authentication_token)
  #   end
  # end

end
