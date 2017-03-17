require 'rails_helper'

RSpec.describe Account, type: :model do
  before(:each) do
    @user = User.create(email: 'biz_owner3@gmail.com', name:'test', zip: '90210', password: 'P@assw0rd', long_tail:true, on_demand: true, dwolla_funding_source: "fundingsourceurl.com")
    @pt = "08b852daabb9da5c5321a767986fc0e2d544edeec8d4c4eb5ae8bfb8a6aa09c50c40588c5f424fadfac93da1b4287bc6c90293ff5ff2dc84ed9da0dafd7ea48f"
    # exchange_token_response = Plaid::User.exchange_token(@pt)
    # User.add_plaid_access_token(@user, exchange_token_response.access_token)
    # @plaid_user = Plaid::User.load(:connect, @user.plaid_access_token)
    # @plaid_user.transactions()
    # @plaid_user.upgrade(:auth)
    # @plaid_user.auth()

    @account = Account.create(
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

  end

  it "removes account from user" do

    expect(Account.where(user_id: @user.id).count).to eq(1)

    Account.remove_accounts(@user)

    expect(Account.where(user_id: @user.id).count).to eq(0)

    user = User.find(@user.id)

    expect(user.on_demand).to be(false)
    expect(user.long_tail).to be(false)
  end

  it "adds failed micro depoit attempt to user" do
    Account.micro_deposit_verification_failed(@account, @user)

    acct = Account.find(@account.id)
    expect(acct.failed_verification_attempt).to eq(1)
  end

end
