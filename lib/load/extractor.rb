require 'nokogiri'

class Extractor

  #kontrola ci stranka nie je chybne hlasenie
  def self.valid_page?(doc)
    return nil if (!doc.css("h1").first.nil? and doc.css("h1").first.content.to_s.strip == "Neočakávaná chyba")
    return nil if (!doc.css("#ctlErrorLabel").first.nil? and doc.css("#ctlErrorLabel").first.content.to_s.match(/Chyba na stránke/i))
    return true
  end

  #extrahuje zoznam ids aktualnych poslancov (return) z html
  def self.extract_actual_deputies_ids(text)
    deputyidregexp = /PoslanecID=(\d+)/
    deputy_ids = []
    text.scan(deputyidregexp){|x| deputy_ids << x[0].to_i}
    puts "#{deputy_ids.length} actual deputies ids extracted"
    return deputy_ids
  end

  #extrahuje poslanca (return) z textu informacii
  def self.extract_deputy(html)
      doc = Nokogiri::HTML(html)
      return nil unless valid_page?(doc)
      deputy = {}
      deputy[:degree] = doc.css("#ctl15_ctlTitul").first.content.to_s.strip
      deputy[:lastname] = doc.css("#ctl15_ctlPriezvisko").first.content.to_s.strip
      deputy[:firstname] = doc.css("#ctl15_ctlMeno").first.content.to_s.strip
      time = doc.css("#ctl15_ctlNarodeny").first.content.match(/(\d+)\. (\d+)\. (\d+)/)
      deputy[:born] = DateTime.civil(time[3].to_i, time[2].to_i, time[1].to_i)
      deputy[:party] = doc.css("#ctl15_ctlKandidovalZa").first.content.to_s.strip
      deputy[:nationality] = doc.css("#ctl15_ctlNarodnost").first.content.to_s.strip
      deputy[:domicile] = doc.css("#ctl15_ctlBydlisko").first.content.to_s.strip
      deputy[:region] = doc.css("#ctl15_ctlKraj").first.content.to_s.strip
      deputy[:email] = doc.css("#ctl15_ctlEmail").first.content.to_s.strip unless (doc.css("#ctl15_ctlEmail").first.nil? or doc.css("#ctl15_ctlEmail").first.content.to_s.strip.length < 5)
#      length < 4 pretoze moze obsahovat znaky ako "", " ", ",", "()", atd.
      deputy[:contact_person] = doc.css("#ctl15_ctlContactPerson").first.content.to_s.strip unless (doc.css("#ctl15_ctlContactPerson").first.nil? or doc.css("#ctl15_ctlContactPerson").first.content.to_s.strip.length < 5)
      puts "deputy details for lastname:#{deputy[:lastname]} extracted"
      return deputy
  end

    #extrahuje hlasovanie (return) z textu (text)
  def self.extract_voting(html)
    doc = Nokogiri::HTML(html)
    return nil unless valid_page?(doc)
    voting = {}
    voting[:subject] = doc.css("#ctl15__hlasHeader__nazovLabel").first.content.to_s
    return nil if voting[:subject] == "(Popis hlasovania)"
    
    voting[:meeting_no] = doc.css("#ctl15__hlasHeader__schodzaLink").first.content.match(/\d+/)[0].to_i
    number_raw = doc.css("#ctl15__hlasHeader__cisHlasovaniaLabel").first.content
    voting[:voting_no] = number_raw.match(/\d+/)[0].to_i unless number_raw.empty?
    time = doc.css("#ctl15__hlasHeader__dateLabel").first.content.match(/(\d+)\. (\d+)\. (\d+) (\d+):(\d+)/)
    voting[:happened_at] = DateTime.civil(time[3].to_i, time[2].to_i, time[1].to_i, time[4].to_i, time[5].to_i)

    voting[:attending_count] = doc.css("#ctl15__hlasHeader__headerCounterPritomni").first.content.to_i
    voting[:voting_count] = doc.css("#ctl15__hlasHeader__headerCounterHlasujucich").first.content.to_i
    voting[:pro_count] = doc.css("#ctl15__hlasHeader__headerCounterZa").first.content.to_i
    voting[:against_count] = doc.css("#ctl15__hlasHeader__headerCounterProti").first.content.to_i
    voting[:hold_count] = doc.css("#ctl15__hlasHeader__headerCounterZdrzaloSa").first.content.to_i
    voting[:not_voting_count] = doc.css("#ctl15__hlasHeader__headerCounterNehlasovalo").first.content.to_i
    voting[:not_attending_count] = doc.css("#ctl15__hlasHeader__headerCounterNepritomni").first.content.to_i
    puts "voting #{voting[:voting_no]} at meeting:#{voting[:meeting_no]} extracted"
    return voting
  end

  #extrahuje hlasy z hlasovania
  def self.extract_votes(html)
    doc = Nokogiri::HTML(html)
    return nil unless valid_page?(doc)

    votes = {}
      party = nil
      doc.css("#ctl15__resultsTable tr td").each do |row|
        if row["class"] == "h3"
          party = row.content
        else
          spans = row.css("span")
          unless spans.empty?
            vote = spans.first.content.tr("[] ", "")
            person = row.css("a").first.content
            votes[party] ||= []
            votes[party] << [vote, person]
          end
        end
      end
      return votes
  end
  
  #extrahuje pocet obdobi (return) z vyberu
  def self.extract_period_count(text)
    match = text.match(/value=".">(\d+)<\/option>/)
    count = match[1].to_i if match
    puts "period count:#{count} extracted"
    return count
  end
  
  def self.extract_last_voting_id(text)
    match = text.match(/sid=schodze\/hlasovanie\/hlasklub&amp;ID=(\d*?)'/)
    return nil if match.nil?
    puts "last voting_id: #{match[1].to_i + 500} estimated"
    return match[1].to_i + 500    
  end

  def self.extract_attendance(text)#deputyid, period)
    attendance = Attendance.new

    match = text.match(/<span id="ctl15_ctlStatZa">(\d*?)<\/span>/)
    attendance.for = match[1].to_i if match
    match = text.match(/<span id="ctl15_ctlStatProti">(\d*?)<\/span>/)
    attendance.against = match[1].to_i if match
    match = text.match(/<span id="ctl15_ctlStatZdrzalSa">(\d*?)<\/span>/)
    attendance.pass = match[1].to_i if match
    match = text.match(/<span id="ctl15_ctlStatNehlasoval">(\d*?)<\/span>/)
    attendance.novote = match[1].to_i if match
    match = text.match(/<span id="ctl15_ctlStatNepritomny">(\d*?)<\/span>/)
    attendance.noattend = match[1].to_i if match
    return attendance
  end

  #extrahuje idcka schodzi v zozname obdobia
  def self.extract_meetings_ids(text)
    array = []
    text.scan(/Ref=\d*?\|(\d*?)\|\d*?\|/){|x|
      array << x[0] unless x[0].nil? or x[0].length==0
    }
    puts "#{array.length} meeting ids extracted"
    return array
  end
  #extrahuje mena zaznamov v zozname schodze
  def self.extract_records_names(text)
    linkregexp = /Download\.aspx\?Type=NRozprava\.RozpravaFinal&amp;Ref=(.*?)\.doc/
    array = []
    text.scan(linkregexp){
      |x| array << x[0] unless x[0].nil? or x[0].length==0
    }
    puts "#{array.length} record names extracted"
    return array
  end

  #extrahuje model zaznamu podla mena zaznamu
  def self.extract_record(recordname)
    match = recordname.match(/^.*?_[^\d]*?(\d*?)_[^\d]*?(\d*?)_[^\d]*?(\d*?)$/)
    if match
      record = Record.new
      record.period = match[1].to_i
      meeting = match[2].to_i
      meeting *=1000 if recordname.match(/SL/) #slavnostna
      record.meeting = meeting
      record.date = Date.parse(match[3])
      puts "record model for period:#{record.period} and meeting:#{record.meeting} extracted"
      return record
    end
    return nil
  end
  
end