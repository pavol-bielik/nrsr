class UserRelation < ActiveRecord::Base
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :deputy, :class_name => "Deputy", :foreign_key => "deputy_id"

end
