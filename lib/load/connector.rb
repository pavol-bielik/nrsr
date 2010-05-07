require File.dirname(__FILE__) + '/../support/downloader'
#require 'nokogiri'
#require 'open-uri'

class Connector 
  def self.download(url, postdata=nil)
    response, data = Downloader.getInstance.download(url, postdata)
    return data
  end

#  def self.download(url)
#    return Nokogiri::HTML(open(url)).to_s
#  end

  def self.download_statute_votings_list_html(id)
    url = "http://www.nrsr.sk/Default.aspx?sid=schodze/hlasovanie/vyhladavanie_vysledok&ZakZborID=13&CisObdobia=4&Popis=&CPT=#{id}&CisSchodze=&DatumOd=&DatumDo=&FullText=False"
    return self.download(url)
  end

  def self.download_statute_info_html(id)
    url = "http://www.nrsr.sk/Default.aspx?sid=zakony/zakon&ZakZborID=13&CisObdobia=4&CPT=#{id}"
    return self.download(url)
  end

  #stiahne html (return) pre pocet obdobi
  def self.download_period_count_html
    url = "http://www.nrsr.sk/default.aspx?sid=schodze/hlasovanie/vyhladavanie"
    return self.download(url)
  end
  #stiahne html (return) pre zoznam aktualnych poslancov
  def self.download_actual_deputies_list_html
    url = "http://www.nrsr.sk/Default.aspx?sid=poslanci/zoznam_abc&ListType=0"
    return self.download(url)
  end
  #stiahne fotku (return) poslanca
  def self.download_deputy_photo_jpeg(depty_id) 
    url = "http://www.nrsr.sk/dynamic/PoslanecPhoto.aspx?PoslanecID=#{depty_id}"
    return self.download(url)
  end
  #stiahne html (return) pre atributy poslanca
  def self.download_deputy_info_html(id)
    url = "http://www.nrsr.sk/Default.aspx?sid=poslanci/poslanec&PoslanecID=#{id}"
    return self.download(url)
  end
  #stiahne html (return) zoznam meetingov
  def self.download_meeting_list_html(count, period)
    url = "http://www.nrsr.sk/appbin/net/NRozprava/TreePane.aspx?content=all"
    out = self.download(url)
    match = out.match(/VIEWSTATE" value="(.*?)"/)
    viewstate = match[1] if match
    return self.download(url, "__EVENTTARGET=Tree&__EVENTARGUMENT=onexpand,#{count - period}&__VIEWSTATE=#{viewstate}")
  end
  #stiahne html so zaznamamy (return) pre obdobie a schodzu
  def self.download_records_html(period, meeting)
    url = "http://www.nrsr.sk/appbin/net/NRozprava/GridPane.aspx?Ref=#{period}#{meeting}|00010101|-1"
    return self.download(url)
  end
  #stiahne zaznam .doc (return) podla id (record_id)
  def self.download_record_doc(recordname)
    url = "http://www.nrsr.sk/appbin/net/NRozprava/Download.aspx?Type=NRozprava.RozpravaFinal&Ref=#{recordname}.doc"
    return self.download(url)
  end 
  #stiahne html (return) pre hlasovanie podla klubov
  def self.download_voting_html(voting_id)
    url = "http://www.nrsr.sk/Default.aspx?sid=schodze/hlasovanie/hlasklub&ID=#{voting_id}"
    return self.download(url)
  end
  #stiahne html (return) pre posledne hlasovanie
  def self.download_last_voting_html
    url = "http://www.nrsr.sk/default.aspx?sid=schodze/hlasovanie/schodze"
    lastregex = /Default.aspx\?sid=schodze\/hlasovanie\/vyhladavanie_vysledok&amp;ZakZborID=13&amp;CisObdobia=\d*?&amp;CisSchodze=\d*?&amp;ShowCisloSchodze=False/
    text = self.download(url)
    match = text.match(lastregex)
    return nil if match.nil?
    return self.download("http://www.nrsr.sk/"+match[0].gsub!("&amp;","&"))
  end

  def self.download_attendance_html(deputyid, period)
    url = "http://www.nrsr.sk/Default.aspx?sid=schodze/hlasovanie/poslanci_vysledok&CisObdobia=#{period}&PoslanecMasterID=#{deputyid}&Popis=&CPT=&CisSchodze="
    return self.download(url)
  end

end