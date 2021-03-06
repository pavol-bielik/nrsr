require 'spec'
require RAILS_ROOT + '/lib/load/extractor'

describe Extractor do

  describe "Deputy" do

    it "should extract actual deputies ids" do
      deputies_ids = Extractor.extract_actual_deputies_ids(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/deputies_list.html"))
      deputies_ids.should == [226, 644, 735, 723, 11, 232, 13, 645, 86, 235, 646, 736, 21, 23, 243, 24, 647, 170, 648, 246, 649, 749, 250, 650, 33, 171, 652, 651, 36, 255, 653, 654, 196, 257, 655, 754, 258, 44, 656, 752, 657, 658, 738, 708, 737, 660, 724, 54, 661, 264, 742, 55, 662, 739, 636, 746, 269, 663, 61, 721, 637, 664, 635, 275, 666, 720, 71, 72, 731, 276, 726, 667, 668, 277, 669, 670, 671, 278, 729, 280, 725, 281, 733, 310, 673, 674, 675, 676, 734, 169, 677, 313, 314, 92, 317, 318, 319, 320, 730, 95, 96, 679, 326, 718, 680, 102, 337, 286, 327, 681, 682, 683, 685, 108, 686, 688, 110, 689, 693, 719, 112, 694, 115, 695, 116, 696, 697, 204, 123, 338, 197, 700, 701, 291, 702, 703, 136, 304, 141, 307, 705, 732, 309, 706, 707, 643, 149, 297, 690, 692]
      deputies_ids.length.should == 150
    end

    it "should extract deputy info with contact" do
      deputy = Extractor.extract_deputy(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/deputy_info_with_contact.html"))
      deputy[:degree].should == "RNDr."
      deputy[:lastname].should == "Mikloško"
      deputy[:firstname].should == "František"
      deputy[:born].should == DateTime.civil(1947, 6, 2)
      deputy[:elected_for].should == "KDH"
      deputy[:nationality].should == "slovenská"
      deputy[:domicile].should == "Bratislava"
      deputy[:region].should == "Bratislavský"
      deputy[:email].should  == "frantisek_miklosko@nrsr.sk"
      deputy[:contact_person].should == "Mia Lukáčová (0905/385814)"
    end

    it "should extract deputy info without contact" do
      deputy = Extractor.extract_deputy(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/deputy_info_without_contact.html"))
      deputy[:degree].should == "MUDr."
      deputy[:lastname].should == "Bastrnák"
      deputy[:firstname].should == "Tibor"
      deputy[:born].should == DateTime.civil(1964, 11, 17)
      deputy[:elected_for].should == "SMK – MKP"
      deputy[:nationality].should == "maďarská"
      deputy[:domicile].should == "Komárno"
      deputy[:region].should == "Nitriansky"
      deputy[:email].should  == "tibor_bastrnak@nrsr.sk"
      deputy[:contact_person].nil?.should == true
    end

    it "should extract deputy info without email" do
      deputy = Extractor.extract_deputy(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/deputy_info_without_email.html"))
      deputy[:degree].should == "Ing."
      deputy[:lastname].should == "Hradecký"
      deputy[:firstname].should == "Boris"
      deputy[:born].should == DateTime.civil(1944, 3, 30)
      deputy[:elected_for].should == "SMER – SD"
      deputy[:nationality].should == "slovenská"
      deputy[:domicile].should == "Bratislava"
      deputy[:region].should == "Bratislavský"
      deputy[:email].nil?.should  == true
      deputy[:contact_person].nil?.should == true
    end

    it "should return nil contact on invalid contact" do
      deputy = Extractor.extract_deputy(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/deputy_info_with_invalid_contact.html"))
      deputy[:contact_person].nil?.should == true
    end

    it "should return nil on invalid pages" do
     deputy1 = Extractor.extract_deputy(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/error_page_1.html"))
     deputy1.nil?.should == true

     deputy2 = Extractor.extract_deputy(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/error_page_2.html"))
     deputy2.nil?.should == true

     deputy3 = Extractor.extract_statute(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/error_page_3.html"))
     deputy3.nil?.should == true
    end

  end

  describe "Voting" do

    it "should parse voting info" do
      voting =  Extractor.extract_voting(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/voting_info.html"))
      voting[:subject].should == "Hlasovanie o pozmeňujúcich a doplňujúcich návrhoch k programu 48. schôdze Národnej rady Slovenskej republiky. Podpr. Belousovová, 1. návrh."
      voting[:short_subject].nil?.should == true
      voting[:meeting_no].should == 48
      voting[:voting_no].should == 3
      voting[:happened_at].should == DateTime.civil(2010, 2, 2, 13, 18)
    end

    it "should parse voting info with short subject" do
      voting =  Extractor.extract_voting(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/voting_info_with_short_subject.html"))
      voting[:short_subject].should == "Hlasovanie o pozmeňujúcich návrhoch zo spoločnej správy výborov - bod 13."
    end

    it "should parse voting statistics" do
      voting = Extractor.extract_voting(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/voting_info.html"))
      voting[:attending_count].should == 108
      voting[:voting_count].should == 96
      voting[:pro_count].should == 44
      voting[:against_count].should == 0
      voting[:hold_count].should == 52
      voting[:not_voting_count].should == 12
      voting[:not_attending_count].should == 42
    end

    it "should parse all votes with parties" do
      votes = Extractor.extract_votes(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/voting_info.html"))
      votes["KDH"].should == [
              ["N", 226, "Abrhan, Pavol"], ["?", 21, "Brocka, Július"], ["?", 196, "Fronc, Martin"], ["?", 657, "Gibalová, Monika"],
              ["?", 55, "Hrušovský, Pavol"], ["N", 635, "Kahanec, Stanislav"], ["0", 280, "Lipšic, Daniel"], ["?", 115, "Sabolová, Mária"],
              ["0", 291, "Šimko, Jozef"],
      ]
      votes["ĽS – HZDS"].size.should == 15
      votes["SDKÚ – DS"].size.should == 28
      votes["SMER – SD"].size.should == 50
      votes["SMK – MKP"].size.should == 15
      votes["SNS"].size.should == 19      
      votes["Poslanci, ktorí nie sú členmi poslaneckých klubov"].size.should == 14
      votes["Poslanci, ktorí nie sú členmi poslaneckých klubov"].last.should == ["?", 697, "Simon, Zsolt"]
    end

    it "should parse info from secret voting" do
      voting = Extractor.extract_voting(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/voting_info_secret.html"))
      voting[:meeting_no].should == 44
      voting[:voting_no].should == nil
      voting[:happened_at].should == DateTime.civil(2009, 12, 9)
      voting[:attending_count].should == 129
      voting[:voting_count].should == 121
      voting[:pro_count].should == 70
      voting[:against_count].should == 25
      voting[:hold_count].should == 26
      voting[:not_voting_count].should == 8
      voting[:not_attending_count].should == 21
    end

    it "should return empty votes from secret voting" do
      votes = Extractor.extract_votes(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/voting_info_secret.html"))
      votes.empty?.should == true
    end


    it "should return nil on invalid voting" do
      voting = Extractor.extract_voting(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/voting_info_empty.html"))
      voting.nil?.should == true
    end

    it "should return nil on invalid pages" do
     voting1 = Extractor.extract_voting(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/error_page_1.html"))
     voting1.nil?.should == true

     voting2 = Extractor.extract_voting(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/error_page_2.html"))
     voting2.nil?.should == true

     voting3 = Extractor.extract_statute(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/error_page_3.html"))
     voting3.nil?.should == true
    end

    it "should extract voting ids from html" do
     voting_ids = Extractor.extract_voting_ids(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/voting_list.html"))
     voting_ids.should == [26827, 26828, 26834, 26835, 26836, 26837, 26838] 
    end

    it "should return [] from empty voting list html" do
     voting_ids = Extractor.extract_voting_ids(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/voting_list_empty.html"))
     voting_ids.empty?.should == true
    end

  end

  describe "Statute" do

    it "should parse statute info with parent" do
      statute = Extractor.extract_statute(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/statute_info_with_parent.html"))
      statute.should == {
              :id => 1526,
              :parent_id => 1440,
              :subject => "Zákon z 10. marca 2010, ktorým sa zriaďuje Slovenský historický ústav v Ríme, vrátený prezidentom Slovenskej republiky na opätovné prerokovanie Národnou radou Slovenskej republiky",
              :short_subject => "Zákon z 10. marca 2010, ktorým sa zriaďuje Slovenský historický ústav v Ríme",
              :statute_type => "Zákon vrátený prezidentom",
              :state => "Uzavretá úloha",
              :result => "(NZ nebol schválený)",
              :date => DateTime.civil(2010, 3, 26)
              }
    end

    it "should parse statute info without parent with document" do
      statute = Extractor.extract_statute(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/statute_info_without_parent.html"))
      statute.should == {
              :id => 1528,
              :subject => "Vládny návrh zákona, ktorým sa mení zákon č. 313/2009 Z. z. o vinohradníctve a vinárstve",
              :short_subject => "Vládny návrh zákona o vinohradníctve a vinárstve",
              :statute_type => "Novela zákona",
              :state => "Redakcia",
              :result => "(NZ postúpil do redakcie)",
              :date => DateTime.civil(2010, 4, 1),
              :doc => "Dynamic/Download.aspx?DocID=344845"
              }
    end

    it "should parse statute in evidence" do
      statute = Extractor.extract_statute(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/statute_info_in_evidence.html"))
      statute.should == {
              :state => "Evidencia",
              :result => "(Tlač evidovaná v podateľni)",
              :subject => "Návrh vlády na skrátené legislatívne konanie o vládnom návrhu zákona, ktorým sa mení zákon č. 313/2009 Z. z. o vinohradníctve a vinárstve"
              }
    end

    it "should return nil on invalid pages" do
     statute1 = Extractor.extract_statute(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/error_page_1.html"))
     statute1.nil?.should == true

     statute2 = Extractor.extract_statute(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/error_page_2.html"))
     statute2.nil?.should == true

     statute3 = Extractor.extract_statute(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/error_page_3.html"))
     statute3.nil?.should == true 
    end

    it "should get last statute id" do
      statute_id = Extractor.extract_last_statute_id(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/statute_list.html"))
      statute_id.should == 1534      
    end

    it "should parse short info from rejected by president" do
      statute = Extractor.extract_statute(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/statute_info_rejected_by_president.html"))
      statute[:short_subject].should == "Zákon o konkurze a reštrukturalizácii"
    end

    it "should parse short info from statute" do
      statute = Extractor.extract_statute(File.read(RAILS_ROOT + "/spec/nrsr/fixtures/statute_info.html"))
      statute[:short_subject].should == "Návrh na vydanie zákona o službách zamestnanosti"
    end

  end

end