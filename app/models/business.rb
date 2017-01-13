# == Schema Information
#
# Table name: businesses
#
#  id                               :integer          not null, primary key
#  name                             :string
#  contribution                     :decimal          precision 8, scale 2
#  frequency                        :string
#  owner                            :integer
#

# ================================================
# RUBY->MODEL->BUSINESS ==========================
# ================================================
class Business < ActiveRecord::Base

  # ----------------------------------------------
  # RELATIONS ------------------------------------
  # ----------------------------------------------
  has_many :users

  # ----------------------------------------------
  # VALIDATIONS ----------------------------------
  # ----------------------------------------------
  validates :name, presence: true

  def self.add_business_owner(user, business_id)
    biz = Business.find(business_id)
    biz.owner = user.id

    biz.save!
  end

end
