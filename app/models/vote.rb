class Vote < ActiveRecord::Base
  belongs_to :deputy, :foreign_key => "deputy_id"
  belongs_to :voting, :foreign_key => "voting_id"

  def self.process_votes(html, voting=nil)
    all_votes = Extractor.extract_votes(html)
    return nil if all_votes.empty?
    i = 0

    deputies = Deputy.all
    new_votes = []

    all_votes.each do |party, votes|
      votes.each do |vote|
         i += 1
         
         party =~ /Poslanci/i ? n_party = "Nezávislý" : n_party = party

        new_votes << "(#{voting}, #{vote[1]}, '#{vote[0]}', '#{n_party}')"

        deputies[deputies.index(vote[1])].update_party(n_party, voting)

      end
    end

    db_con = Vote.connection
    db_con.insert_sql("INSERT INTO `votes` (`voting_id`, `deputy_id`,`vote`, `party`) VALUES#{new_votes.join(",")}")
    
    puts "# #{i} votes created"
  end

#  def ==(input_id)
#    return true if deputy_id == input_id
#    false
#  end

end
