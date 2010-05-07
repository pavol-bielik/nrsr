class Statute < ActiveRecord::Base
  has_many :votings
  belongs_to :parent, :class_name => "Statute",  :foreign_key => "parent_id"
end
