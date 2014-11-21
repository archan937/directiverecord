class Article < ActiveRecord::Base
  belongs_to :author, :class_name => "User"
  has_many :comments
  has_and_belongs_to_many :tags
end
