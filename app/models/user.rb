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
#

# ================================================
# RUBY->MODEL->USER ==============================
# ================================================
class User < ActiveRecord::Base

  # ----------------------------------------------
  # DEVISE ---------------------------------------
  # ----------------------------------------------
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # ----------------------------------------------
  # RELATIONS ------------------------------------
  # ----------------------------------------------
  has_one  :checking

  has_many :public_tokens
  has_many :accounts
  has_many :transactions

  # ----------------------------------------------
  # VALIDATIONS ----------------------------------
  # ----------------------------------------------
  validate :email_is_unique, on: :create
  validate :password_strength

  # validate :mobile_number_is_unique, on: :update
  validates :mobile_number, phone: { possible: false, allow_blank: true, types: [:mobile] }

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

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

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

end
