class Vote < ActiveRecord::Base
  belongs_to :deputy, :foreign_key => "deputy_id"
  belongs_to :voting, :foreign_key => "voting_id"

  def self.process_votes(html, voting=nil)
    all_votes = Extractor.extract_votes(html)
    return nil if all_votes.empty?
    i = 0

    all_votes.each do |party, votes|
      votes.each do |vote|
         i += 1
         
         if party =~ /Poslanci/i
            n_party = "Nezávislý"
            vote.deputy.update_party(n_party, voting)
         else
            n_party = party
         end

         Vote.create(:voting_id => voting,
                       :deputy_id => vote[1],
                       :vote => vote[0],
                       :party => n_party)
      end
    end
    puts "# #{i} votes created"
  end

  def ==(input_id)
    return true if deputy_id == input_id
    false
  end

end
