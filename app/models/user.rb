class User < ActiveRecord::Base
  has_many :user_votes, :class_name => "UserVote"
  has_many :user_relations, :class_name => "UserRelation", :foreign_key => "user_id"

  acts_as_authentic do |c|
      c.logged_in_timeout = 10.minutes # default is 10.minutes
  end

  def create_relations
    deputies = Deputy.find(:all, :select => "id")
    user_relations = UserRelation.find(:all, :conditions => ["user_id = ?", id])

    new_relations = []
    deputies.each do |deputy|
      new_relations << "(0, 0, #{id}, #{deputy.id})" if user_relations.index(deputy.id).nil?
    end

    db_con = UserRelation.connection
    db_con.insert_sql("INSERT INTO `user_relations` (`votes`, `relation`, `user_id`, `deputy_id`) VALUES#{new_relations.join(",")}")

  end

  def delete_relations
    relations = []
    self.user_relations.each do |rel|
      relations << rel.id
    end
    UserRelation.delete(relations)
  end

  def add_voting_relations(voting_id, old_vote="0")
    old_vote == "0" ? inc = 1 : inc = 0

    votes = Vote.find(:all, :conditions => {:voting_id => voting_id})
    user_vote = UserVote.find(:first, :conditions => ["voting_id = ? and user_id = ?", voting_id , id])

    update = {}
    votes.each do |vote|
        value = DeputyRelation::RELATION[user_vote.vote][vote.vote] - DeputyRelation::RELATION[old_vote][vote.vote]
        #V pripade ze uzivatel predtym nehlasoval, je old_vote="0" a hodnota RELATION[old_vote][vote.vote] = 0
        update[value] ||= []
        update[value] << vote.deputy_id
    end

    update.each do |key, value|
       UserRelation.update_all("relation = relation + #{key}, votes = votes + #{inc}", ["user_id = ? and deputy_id IN (#{value.join(",")})",id])
    end

    puts "#User relations for voting #{voting_id} added "
    return true
  end

end
