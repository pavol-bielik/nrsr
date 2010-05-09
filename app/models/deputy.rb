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

  def photo=(file)
    super(File.basename(file.path))
  end

end
