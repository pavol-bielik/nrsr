class Statute < ActiveRecord::Base
  has_many :votings
  belongs_to :parent, :class_name => "Statute",  :foreign_key => "parent_id"

    def self.create_or_update(id)
    #return nil if Statute.exists?(id)
    statute_html = Connector.download_statute_info_html(id)
    statute_attr = Extractor.extract_statute(statute_html)
    return nil if statute_attr.nil?
    if Statute.exists?(id) then
      statute = Statute.find(id)
      statute.update_attributes(statute_attr)
#      statute.update_attribute(:type, statute_attr[:type])
      puts "statute #{id} updated"
    else
      statute = Statute.new(statute_attr)
#      statute.type = statute_attr[:type]
      statute.id = id
      statute.save
      puts "statute #{id} created"
    end
    return statute  
#    return statute_html  
  end

end
