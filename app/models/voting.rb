class Voting < ActiveRecord::Base
  has_many :votes, :class_name => "Vote"
  belongs_to :statute
end
