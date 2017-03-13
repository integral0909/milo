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

require 'test_helper'

class TransferTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
