class Comment < ActiveRecord::Base
  belongs_to :article
  belongs_to :poster, :class_name => "User"
end
