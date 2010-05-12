class User < ActiveRecord::Base
  has_many :user_votes, :class_name => "UserVote"
  has_many :user_relations, :class_name => "UserRelation", :foreign_key => "user_id"

  acts_as_authentic do |c|
      c.logged_in_timeout = 10.minutes # default is 10.minutes
  end

  def create_relations
    deputies = Deputy.find(:all, :select => "id")
    deputies.each do |deputy|
      unless UserRelation.exists?(:user_id => id, :deputy_id => deputy.id) then
        UserRelation.create(:user_id => id,
                              :deputy_id => deputy.id)
      end
    end
  end

  def add_voting_relations(voting_id)

    votes = Vote.find(:all, :conditions => {:voting_id => voting_id})
    user_vote = UserVote.find(:first, :conditions => {:user_id => id})

    votes.each do |vote|
        relation = UserRelation.find(:first, :conditions => ["user_id = ? and deputy_id = ?", id, vote.deputy_id])
        relation.relation += DeputyRelation::RELATION[user_vote.vote][vote.vote]
        relation.votes += 1
        relation.save
    end

    puts "#User relations for voting #{voting_id} added"
    return true
  end

end