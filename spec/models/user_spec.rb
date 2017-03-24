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
#  budget                 :decimal(8, 2)
#

require 'rails_helper'

RSpec.describe User, type: :model do
  before(:each) do
    @user = User.create!(email: 'test1@gmail.com', name:'test', zip: '90210', password: 'P@assw0rd')
  end

  describe "User" do
    it "created successfully" do
      user = User.new(email: 'test@gmail.com', name:'test', zip: '90210', password: 'P@assw0rd')
      expect(user).to be_valid
    end

    it "not created bc password is weak" do
      user = User.new(email: 'test@gmail.com', name:'test', zip: '90210', password: 'weaksauce')
      expect(user).to_not be_valid
    end

    it "not created when email is taken" do
      user2 = User.create(email: 'test1@gmail.com', name:'test', zip: '90210', password: 'P@assw0rd')
      expect(user2).to_not be_valid
    end

    it "sets last name when included in name" do
      user = User.create(email: 'test2@gmail.com', name:'test case', zip: '90210', password: 'P@assw0rd')
      expect(user.last_name).to eq('case')
    end

    it "sets plaid access_token" do
      User.add_plaid_access_token(@user, '12345')
      expect(@user.plaid_access_token).to eq('12345')
    end

    it "adds account balance" do
      User.add_account_balance(@user, '2')
      expect(@user.account_balance).to eq(200)
    end

    it "can decrease account balance" do
      @user.account_balance = '500'
      @user.save!

      User.decrease_account_balance(@user, '2')
      expect(@user.account_balance).to eq(300)
    end

    it "verifies bank" do
      User.bank_verified(@user)
      expect(@user.bank_not_verified).to eq(false)
    end

    it "sets bank as long tail account" do
      User.add_long_tail(@user)
      expect(@user.bank_not_verified).to eq(true)
      expect(@user.long_tail).to eq(true)
    end
  end
end
