#require RAILS_ROOT + "/lib/load/connector"
#require RAILS_ROOT + "/lib/load/extractor"
require 'fileutils'

class Deputy < ActiveRecord::Base
  has_many :votes, :class_name => "Vote"
  has_many :relations, :class_name => "DeputyRelation", :foreign_key => "deputy1_id"

  PARTY = { "SMER – SD" => 2,
            "SDKÚ – DS" => 1,
            "SNS" => 3,
            "SMK – MKP" => 4,
            "ĽS – HZDS" => 5,
            "KDH" => 6 }

  def self.create_deputies
    actual_deputies_html = Connector.download_actual_deputies_list_html
    deputies_ids = Extractor.extract_actual_deputies_ids(actual_deputies_html)
    deputies_ids.each do |id|
        next if Deputy.exists?(id)
        text = Connector.download_deputy_info_html(id)
        next if text.nil?
        deputy_attr = Extractor.extract_deputy(text)
        next if deputy_attr.nil?
        deputy = Deputy.new(deputy_attr)
        deputy.party = deputy.elected_for
        deputy.id = id
        if File.file?("#{PHOTOS_DIR}/#{deputy.id}.jpeg") then
          photofile = File.new("#{PHOTOS_DIR}/#{deputy.id}.jpeg", "rb")
        else
          photo = Connector.download_deputy_photo_jpeg(deputy.id)
          photofile = File.new("#{PHOTOS_DIR}/#{deputy.id}.jpeg", "wb")
          photofile.write(photo)
        end
        deputy.photo = photofile
        deputy.save
        puts "#deputy #{deputy.id} saved"
    end
  end

  def create_deputy_relations(deputies)

    new_relations = []
    deputies.each do |deputy|
      next if deputy.id == id
      new_relations << "(0, 0, #{id}, #{deputy.id})"
    end

    db_con = DeputyRelation.connection
    db_con.insert_sql("INSERT INTO `deputy_relations` (`votes`, `relation`, `deputy1_id`, `deputy2_id`) VALUES#{new_relations.join(",")}")

  end

  def self.create_deputies_relations
    deputies = Deputy.all(:select => "id")
    deputies.each do |deputy|
      deputy.create_deputy_relations(deputies)
      puts "#Relations for deputy: #{deputy.id} added"
    end
  end

  def self.add_voting_relations(voting_id)

    votes = Vote.find(:all, :conditions => {:voting_id => voting_id})
    i = 1
    votes.each do |vote|
      votes.each do |vote2|
        next if vote.id == vote2.id
        relation = DeputyRelation.find(:first, :conditions => ["deputy1_id = ? and deputy2_id = ?", vote.deputy_id, vote2.deputy_id])
        next if relation.nil?
        relation.relation += DeputyRelation::RELATION[vote.vote][vote2.vote]
        relation.votes += 1
        relation.save
      end
      puts "#Vote #{i} added"
      i += 1
    end

    return true
  end

  def self.add_voting_relations_2(voting_id)
    votes = Vote.find(:all, :conditions => {:voting_id => voting_id})

    dep_votes = {}

    votes.each do |vote|
      dep_votes[vote.deputy_id] = vote.vote
    end

    DeputyRelation.find_each do |relation|
      relation.relation += DeputyRelation::RELATION[dep_votes[relation.deputy1_id]][dep_votes[relation.deputy2_id]]
      relation.votes += 1
      relation.save
    end

    return true
  end

    def self.add_voting_relations_list(voting_ids)

      votes = []
      voting_ids.each do |voting_id|
        votes += Vote.find(:all, :conditions => {:voting_id => voting_id})
      end

      dep_votes = {}

      votes.each do |vote|
        dep_votes[vote.deputy_id] = [] if dep_votes[vote.deputy_id].nil?
        dep_votes[vote.deputy_id] << vote.vote
      end

      len = voting_ids.length

      DeputyRelation.find_each do |relation|
        value = 0
        (0).upto(len - 1) do |i|
          value += DeputyRelation::RELATION[dep_votes[relation.deputy1_id][i]][dep_votes[relation.deputy2_id][i]]
        end
        relation.relation += value
        relation.votes += len
        relation.save
      end

      puts "##{votes.length} relations added"
    return true
  end

  def self.add_voting_relations_list_2(voting_ids)

      votes = []
      voting_ids.each do |voting_id|
        votes += Vote.find(:all, :conditions => {:voting_id => voting_id})
      end

      dep_votes = {}

      votes.each do |vote|
        dep_votes[vote.deputy_id] = [] if dep_votes[vote.deputy_id].nil?
        dep_votes[vote.deputy_id] << vote.vote
      end

      len = voting_ids.length
      deputy_relations = DeputyRelation.all
      update = {}
      deputy_relations.each do |relation|
         value = 0
        (0).upto(len - 1) do |i|
          value += DeputyRelation::RELATION[dep_votes[relation.deputy1_id][i]][dep_votes[relation.deputy2_id][i]]
        end
        update[value] ||= []
        update[value] << relation.id
      end

      update.each do |key, value|
         DeputyRelation.update_all("relation = relation + #{key}, votes = votes + #{len}", "id IN (#{value.join(",")})")
      end

  end

  def photo=(file)
    super(File.basename(file.path))
  end

  def update_party(n_party, n_voting_id=nil)
    unless (n_party == party or n_voting_id.nil?)
      n_voting = Voting.find(n_voting_id)
      unless (party_since.nil? or party_since > n_voting.happened_at.to_date)
        n_party_since = party_since
      else
        n_party_since = n_voting.happened_at.to_date
      end
      self.update_attributes(:party => n_party, :party_since => n_party_since)
    end
  end

#  def photo
#    return File.open("data/photos/#{super()}", "rb")
#  end
#

  def ==(dep_id)
    return true if dep_id == id
    return false
  end

end
