class User < ActiveRecord::Base
  has_one :foo, :class_name => "Article", :foreign_key => "foo_id"
end
