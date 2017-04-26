# == Schema Information
#
# Table name: transfers
#
#  id               :integer          not null, primary key
#  dwolla_url       :string
#  user_id          :string
#  roundup_count    :string
#  status           :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  transfer_type    :string
#  roundup_amount   :string
#  date             :string
#  tech_fee_charged :boolean
#  business_id      :integer
#

require 'rails_helper'

RSpec.describe Transfer, type: :model do
  it "is created successfully" do
    b = Business.create(name: "Test Biz")
    user = User.create!(email: 'trans@gmail.com', name:'test', zip: '90210', password: 'P@assw0rd')

    Transfer.create_transfers(user, b.id, "transfer_url", "success", "200", "5", "deposit", "current_date", false)

    expect(Transfer.first.user_id).to eq(user.id.to_s)
  end
end
