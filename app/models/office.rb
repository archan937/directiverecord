class Office < ActiveRecord::Base
  has_many :employees

  default_scope lambda {
    if $default_office_scope
      where $default_office_scope
    end
  }

  scope :usa, -> {
    where(:country => "USA")
  }

end
