class UserVote < ActiveRecord::Base
  belongs_to :user, :foreign_key => "user_id"
  belongs_to :voting, :foreign_key => "voting_id"
end
