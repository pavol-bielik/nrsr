class Voting < ActiveRecord::Base
  has_many :votes, :class_name => "Vote"
  belongs_to :statute

  DEFAULT_POPULARITY = 1000

  def self.create_voting(id, statute=nil)
    return nil if Voting.exists?(id)
    voting_html = Connector.download_voting_html(id)
    voting_attr = Extractor.extract_voting(voting_html)
    return nil if voting_attr.nil?
    voting = Voting.new(voting_attr)
    voting.id = id
    voting.statute_id = statute unless statute.nil?
    voting.popularity = DEFAULT_POPULARITY
    voting.save
    puts "voting #{id} created"
    return voting_html
#    Vote.process_votes(voting_html,id)
  end

end
