# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default("0"), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited                :boolean          default("false")
#  admin                  :boolean          default("false")
#  referral_code          :string
#  name                   :string
#  zip                    :string
#  mobile_number          :string
#  verification_code      :string
#  is_verified            :boolean
#  dwolla_id              :string
#  dwolla_funding_source  :string
#  on_demand              :boolean
#  agreement              :boolean
#  address                :string
#  city                   :string
#  state                  :string
#  plaid_access_token     :string
#  failed_attempts        :integer          default("0"), not null
#  unlock_token           :string
#  locked_at              :datetime
#  avatar_file_name       :string
#  avatar_content_type    :string
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#  account_balance        :integer
#  business_id            :integer
#  long_tail              :boolean
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string
#  invitations_count      :integer          default("0")
#  bank_not_verified      :boolean
#  pause_savings          :boolean
#  employer_contribution  :integer
#  pending_contribution   :integer
#  first_name             :string
#  last_name              :string
#  auth_token             :string           default("")
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
  before_create :generate_authentication_token!

  # ----------------------------------------------
  # NESTED-ATTRIBUTES ----------------------------
  # ----------------------------------------------
  accepts_nested_attributes_for :business

  # ----------------------------------------------
  # VALIDATIONS ----------------------------------
  # ----------------------------------------------
  validates :auth_token, uniqueness: true
  validates :name, presence: true
  validates :zip, presence: true
  validates :email, presence: true, length: { maximum: 255 },
              format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i },
              uniqueness: { case_sensitive: false }
  validate :password_strength

  # validate :mobile_number_is_unique, on: :update
  validates :mobile_number, phone: { possible: false, allow_blank: true, types: [:mobile] }

  # ----------------------------------------------
  # CALLBACKS ------------------------------------
  # ----------------------------------------------
  before_save :set_first_name
  before_save :set_last_name
  after_create :subscribe_user_to_mailing_list

  # ----------------------------------------------
  # AVATAR ---------------------------------------
  # ----------------------------------------------
  has_attached_file :avatar, styles: { large: "512x512", medium: "300x300", thumb: "100x100" }
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  # ----------------------------------------------
  # GENERATE-AUTH-TOKEN! -------------------------
  # ----------------------------------------------
  def generate_authentication_token!
  	begin
  		self.auth_token = Devise.friendly_token
  	end while self.class.exists?(auth_token: auth_token)
  end

  # ----------------------------------------------
  # SET-FIRST-NAME -------------------------------
  # ----------------------------------------------
  def set_first_name
    self.first_name = name.split.first
  end

  # ----------------------------------------------
  # SET-LAST-NAME --------------------------------
  # ----------------------------------------------
  def set_last_name
    if name.split.count > 1
      self.last_name = name.split[1..-1].join(' ')
    end
  end

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
  def self.add_account_balance(user, amount, quick_save=nil)
    # roundup amount converted to cents
    amount_in_cents = (amount.to_f * 100).round(0)

    # Add current roundups
    self.add_roundup(user, amount_in_cents)

    # Check if the user is associated with a business
    if !user.business_id.nil? && quick_save.nil?
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

  # ----------------------------------------------
  # EMAILS ---------------------------------------
  # ----------------------------------------------
  def queue_longtail_drip_emails(user, funding_account)
    Resque.enqueue_at(3.days.from_now, SendLongtailDripEmail, user.id, funding_account.id, 1)
    Resque.enqueue_at(5.days.from_now, SendLongtailDripEmail, user.id, funding_account.id, 2)
    Resque.enqueue_at(7.days.from_now, SendLongtailDripEmail, user.id, funding_account.id, 3)
    Resque.enqueue_at(12.days.from_now, SendLongtailDripEmail, user.id, funding_account.id, 4)
  end

  # ----------------------------------------------
  # TO-JSON --------------------------------------
  # ----------------------------------------------
  def to_json(options={})
  	options[:except] ||= [:auth_token]
  	super(options)
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # ADD-ROUNDUP ----------------------------------
  # ----------------------------------------------
  def self.add_roundup(user, amount)
    !user.account_balance.nil? ? user.account_balance += amount : user.account_balance = amount
  end

  # ----------------------------------------------
  # EMAIL-UNIQUE ---------------------------------
  # ----------------------------------------------
  # def email_is_unique
  #   # Don't validate email if errors are already present
  #   return false unless self.errors[:email].empty?
  #   unless User.find_by_email(email).nil?
  #     errors.add(:email, "is already taken by another account")
  #   end
  # end

  # ----------------------------------------------
  # STRONG-PASSWORD ------------------------------
  # ----------------------------------------------
  def password_strength
    if password.present? and not password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)./)
      errors.add :password, "must include at least one lowercase letter, one uppercase letter, and one number."
    end
  end

  # ----------------------------------------------
  # SUBSCRIBE-USER-NEWSLETTER --------------------
  # ----------------------------------------------
  # only add new users from production
  def subscribe_user_to_mailing_list
    if Rails.env.production?
      SubscribeUserToMailingListJob.perform_later(self)
    end
  end

end
