class Voting < ActiveRecord::Base
  has_many :votes, :class_name => "Vote"
  belongs_to :statute

  DEFAULT_POPULARITY = 1000

  def self.create_voting(id, statute=nil)
    return if Voting.exists?(id)
    voting_html = Connector.download_voting_html(id)
    voting_attr = Extractor.extract_voting(voting_html)
    return if voting_attr.nil?
    voting = Voting.new(voting_attr)
    voting.id = id
    voting.statute_id = statute unless statute.nil?
    voting.popularity = DEFAULT_POPULARITY
    voting.save
  end

  def self.process_votes(html, voting=nil)
    all_votes = Extractor.extract_votes(html)
    return if all_votes.empty?

    all_votes.each do |party, votes|
      votes.each do |vote|
#         Voting.create(:voting_id => voting,
#                       :deputy_id => Deputy.find_)
      end
    end

  end


end
