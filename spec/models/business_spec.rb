require 'rails_helper'

RSpec.describe Business, type: :model do
  before(:each) do
    @user = User.create(email: 'biz_owner@gmail.com', name:'test', zip: '90210', password: 'P@assw0rd')
    @biz = Business.create(name: 'test business', owner: nil, current_contribution: 100)
  end

  it "adds business owner to business" do
    Business.add_business_owner(@user, @biz.id)

    biz = Business.find(@biz.id)
    expect(biz.owner).to eq(@user.id)
  end

  it "resets current contribution" do
    Business.reset_current_contribution(@biz.id)

    biz = Business.find(@biz.id)
    expect(biz.current_contribution).to eq(nil)
  end
end
