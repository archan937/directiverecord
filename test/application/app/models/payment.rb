class Payment < ActiveRecord::Base
  belongs_to :customer
end
