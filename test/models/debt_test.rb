# == Schema Information
#
# Table name: debts
#
#  id              :integer          not null, primary key
#  account_name    :string
#  account_number  :string
#  debt_type       :string
#  begin_balance   :decimal(, )
#  current_balance :decimal(, )
#  minimum_payment :decimal(, )
#  credit_limit    :decimal(, )
#  apr             :decimal(, )
#  due_date        :date
#  user_id         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class DebtTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
