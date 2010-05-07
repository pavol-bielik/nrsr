class Vote < ActiveRecord::Base
  belongs_to :deputy, :foreign_key => "deputy_id"
  belongs_to :voting, :foreign_key => "voting_id"
end
