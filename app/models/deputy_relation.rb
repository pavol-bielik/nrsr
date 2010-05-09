class DeputyRelation < ActiveRecord::Base
  belongs_to :deputy1, :class_name => "Deputy", :foreign_key => "deputy1_id"
  belongs_to :deputy2, :class_name => "Deputy", :foreign_key => "deputy2_id"

  RELATION = { "Z" => {"Z" => 10, "P" => 0, "?" => 2, "N" => 2, "0" => 0},
               "P" => {"Z" => 0, "P" => 10, "?" => 7, "N" => 7, "0" => 0},
               "?" => {"Z" => 5, "P" => 5, "?" => 5, "N" => 4, "0" => 3},
               "N" => {"Z" => 5, "P" => 5, "?" => 5, "N" => 4, "0" => 3},
               "0" => {"Z" => 0, "P" => 0, "?" => 0, "N" => 0, "0" => 0} }

  def self.create_deputy_relations(id)
    deputies = Deputy.find(:all, :select => "id")
    deputies.each do |deputy|
      next if deputy.id == id
      unless DeputyRelation.exists?(:deputy1_id => id, :deputy2_id => deputy.id) then
        DeputyRelation.create(:deputy1_id => id,
                              :deputy2_id => deputy.id)
      end
    end
  end

  def self.create_deputies_relations
    deputies = Deputy.all(:select => "id")
    deputies.each do |deputy|
      create_deputy_relations(deputy.id)
      puts "#Relations for deputy: #{deputy.id} added"
    end
  end

  def self.add_voting_relations(voting_id)

    votes = Vote.find(:all, :conditions => {:voting_id => voting_id})
    #deputies = Deputy.find(:all, :joins => :votes, :conditions => ["voting_id = ?", voting_id])#:select => "id")#, :joins => :relations)
    #relations = DeputyRelation.find(:all)
    i = 1
    votes.each do |vote|
      votes.each do |vote2|
        next if vote.id == vote2.id
        relation = DeputyRelation.find(:first, :conditions => ["deputy1_id = ? and deputy2_id = ?", vote.deputy_id, vote2.deputy_id])
        relation.relation += DeputyRelation::RELATION[vote.vote][vote2.vote]
        relation.votes += 1
        relation.save
      end
      puts "#Vote #{i} added"
      i += 1
    end

    return true
#    votes.each do |vote|
#       deputies.each do |deputy|
#         next if vote.deputy_id == deputy.id
#         relation = deputy.relations.find(:first, :conditions => ["deputy2_id = ?", vote.deputy_id])
#         #relation = relations[relations.index([deputy.id, vote.deputy_id])]
#         relation.relation += DeputyRelation::RELATION[deputy.vote][vote.vote]
#         relation.votes += 1
#         relation.save
#       end
#    end
  end

end
