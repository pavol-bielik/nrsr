class Voting < ActiveRecord::Base
  has_many :votes, :class_name => "Vote"
  has_many :user_votes, :class_name => "UserVote"
  belongs_to :statute

  def self.create_voting(id, statute=nil)
    return nil if Voting.exists?(id)
    voting_html = Connector.download_voting_info_html(id)
    voting_attr = Extractor.extract_voting(voting_html)
    return nil if voting_attr.nil?
    return nil if voting_attr[:voting_no].nil? #Tajne hlasovanie
    voting = Voting.new(voting_attr)
    voting.id = id
    voting.statute_id = statute unless statute.nil?
    voting.subject =~ /Hlasovanie o návrhu zákona ako o celku/i ? popularity = id + 1000 : popularity = id
    popularity += voting_attr[:voting_count]
    if voting.voting_count > 80
      ratio = (voting.pro_count - voting.against_count - voting.hold_count)
      ratio.abs == 0 ? popularity += 2000 : popularity += 2000/ratio.abs
    end
    voting.popularity = popularity.round
    voting.save
    puts "voting #{id} created"
    return voting_html
#    Vote.process_votes(voting_html,id)
  end

end
