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
      puts "statute #{id} updated"
    else
      statute = Statute.new(statute_attr)
      return nil if statute[:result] =~ /(NZ vzal navrhovateľ späť)/i
      return nil if statute[:state] =~ /Evidencia/i
      return nil if statute[:state] =~ /Rozhodnutie predsedu NR SR/i
      return nil if statute[:statute_type] =~ /Iný typ/i
      return nil if statute[:statute_type] =~ /Správa/i
      return nil if statute[:statute_type] =~ /Informácia/i
      statute.id = id
      statute.save
      puts "statute #{id} created"
    end
    return statute  
#    return statute_html  
  end

  def self.search(page, statute_type)
    unless statute_type.nil? or statute_type == "Všetky"
      paginate :per_page => 10, :page => page, :order => 'id DESC', :conditions => ["statute_type = ?",statute_type], :include => :votings
    else
      paginate :per_page => 10, :page => page, :order => 'id DESC', :include => :votings
    end
  end

end
