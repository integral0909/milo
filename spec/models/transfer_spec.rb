require 'rails_helper'

RSpec.describe Transfer, type: :model do
  it "is created successfully" do
    b = Business.create(name: "Test Biz")
    user = User.create!(email: 'trans@gmail.com', name:'test', zip: '90210', password: 'P@assw0rd')

    Transfer.create_transfers(user, b.id, "transfer_url", "success", "200", "5", "deposit", "current_date", false)

    expect(Transfer.first.user_id).to eq(user.id.to_s)
  end
end
