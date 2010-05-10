#require RAILS_ROOT + "/lib/load/connector"
#require RAILS_ROOT + "/lib/load/extractor"
require 'fileutils'

class Deputy < ActiveRecord::Base
  has_many :votes, :class_name => "Vote"
  has_many :relations, :class_name => "DeputyRelation", :foreign_key => "deputy1_id" 

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

  def create_deputy_relations
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
      deputy.create_deputy_relations
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

  def photo=(file)
    super(File.basename(file.path))
  end

end
