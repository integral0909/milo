# == Schema Information
#
# Table name: token_data
#
#  id            :integer          not null, primary key
#  expires_in    :integer
#  scope         :string
#  account_id    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  access_token  :string
#  refresh_token :string
#

require 'test_helper'

class TokenDataTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
