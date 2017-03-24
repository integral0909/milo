# == Schema Information
#
# Table name: checkings
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  plaid_acct_id :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe Checking, type: :model do

  it "adds checking with user and plaid account" do
    @user = User.create(email: 'biz_owner3@gmail.com', name:'test', zip: '90210', password: 'P@assw0rd')
    account = Account.create(
      plaid_acct_id: "QPO8Jo8vdDHMepg41PBwckXm4KdK1yUdmXOwK",
      account_name: "Plaid Savings",
      account_number: "9606",
      available_balance: 1203.42,
      current_balance: 1274.93,
      institution_type: "fake_institution",
      name: "Plaid Savings",
      numbers: "{:routing=>\"021000021\", :account=>\"9900009606\", :wireRouting=>\"021000021\"}",
      acct_subtype: "checking",
      acct_type: "depository",
      user_id: @user.id,
      public_token_id: 32,
      checking_id: nil,
      bank_account_number: "9900009606",
      bank_routing_number: "021000021",
      failed_verification_attempt: nil
     )

     accounts = Account.where(user_id: @user.id, acct_subtype: "checking")

     checking = Checking.create_checking(accounts)

     expect(checking).to be_valid
  end
end
