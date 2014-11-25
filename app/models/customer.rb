class Customer < ActiveRecord::Base
  belongs_to :sales_rep_employee, :class_name => "Employee"
  has_many :orders
  has_many :payments
  has_and_belongs_to_many :tags
end
