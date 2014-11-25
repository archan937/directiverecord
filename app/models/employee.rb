class Employee < ActiveRecord::Base
  belongs_to :office
  belongs_to :reportee, :class_name => "Employee"
  has_many :customers, :foreign_key => "sales_rep_employee_id"
end
