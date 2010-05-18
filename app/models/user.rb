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

  def delete_relations
    relations = []
    self.user_relations.each do |rel|
      relations << rel.id
    end
    UserRelation.delete(relations)
  end

  def add_voting_relations(voting_id, old_vote="0")

    votes = Vote.find(:all, :conditions => {:voting_id => voting_id})
    user_vote = UserVote.find(:first, :conditions => ["voting_id = ? and user_id = ?", voting_id , id])

    votes.each do |vote|
        value = DeputyRelation::RELATION[user_vote.vote][vote.vote] - DeputyRelation::RELATION[old_vote][vote.vote]
        relation = UserRelation.find(:first, :conditions => ["user_id = ? and deputy_id = ?", id, vote.deputy_id])
        relation.relation += value
        relation.votes += 1 if old_vote == "0"
        relation.save
    end

    puts "#User relations for voting #{voting_id} added "
    return true
  end

end
