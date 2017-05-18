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

# ================================================
# RUBY->MODEL->TRANSFER ==========================
# ================================================
class Transfer < ActiveRecord::Base

  # ----------------------------------------------
  # RELATIONS ------------------------------------
  # ----------------------------------------------
  belongs_to :business

  # ----------------------------------------------
  # TRANSFER-CREATE ------------------------------
  # ----------------------------------------------
  def self.create_transfers(user, biz_id, transfer_url, transfer_status, roundup_amount, roundup_count, transfer_type, current_date, tech_fee_charged)
    # creat transfer object on roundup deposit
    Transfer.create(
      user_id: user.id,
      business_id: biz_id,
      dwolla_url: transfer_url,
      status: transfer_status,
      roundup_amount: roundup_amount,
      roundup_count: roundup_count,
      transfer_type: transfer_type,
      tech_fee_charged: tech_fee_charged,
      date: current_date
    )
  end

  def self.update_status(transfer_id, status)
    tr = Transfer.find(transfer_id)
    tr.status = status

    tr.save!
  end

end
