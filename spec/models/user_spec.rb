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
