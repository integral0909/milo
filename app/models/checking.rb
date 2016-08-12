class Checking < ActiveRecord::Base
  
  belongs_to :user
  has_one :account

end
