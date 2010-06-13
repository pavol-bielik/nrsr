namespace :load do

  desc "Create deputies"
  task(:create_deputies => :environment) do
    Deputy.create_deputies
    Deputy.create_deputies_relations
  end

#  desc "Update Statutes with dependencies"
#  task(:update_statutes_with_dependecies => :environment) do
#    statutes = Statute.find(:all, :conditions => "state <> 'Uzavretá úloha'")
#    statutes.each do |statute|
#      statute_id = statute.id
#      while true do
#        statute = Statute.create_or_update(statute_id)
#        break if statute.nil?
#        voting_list = Connector.download_statute_votings_list_html(statute_id)
#        break if voting_list.nil?
#        voting_ids = Extractor.extract_voting_ids(voting_list)
#        voting_ids.each do |voting|
#          next if Voting.exists?(voting)
#          voting_html = Voting.create_voting(voting, statute_id)
#          Vote.process_votes(voting_html,voting)
#          Deputy.add_voting_relations(voting)
#        end
#        break if statute.parent_id.nil?
#        statute_id = statute.parent_id
#      end
#    end
#  end

  desc "Create new statutes with dependecies from, to"
  task :create_statutes_range, :from, :to, :needs => :environment do |t, args|
    args.with_defaults(:from => -1,:to => Statute.maximum('id'))
    puts "args: #{args[:from]}, #{args[:to]}"
    if args[:from] == -1
      puts "Wrong input range"
      return
    end
    last_statute_html = Connector.download_last_statute_html
    last_statute_id = Extractor.extract_last_statute_id(last_statute_html)
    if last_statute_id.nil?
      puts "Warning: Could't extract last statute id"
#      return
    end
     last_statute_id = args[:to] #if !last_statute_id.nil? and last_statute_id > args[:to] #Vacsi rozhas ako posledne hlasovanie

    (args[:from]).upto(last_statute_id) do |statute_id|
      while true do
        statute = Statute.create_or_update(statute_id)    #Vytvorenie navrhu zakona
        break if statute.nil?
        voting_list = Connector.download_statute_votings_list_html(statute_id)     #Stiahnutie zoznamu hlasovani k navrhu zakona
        break if voting_list.nil?
        voting_ids = Extractor.extract_voting_ids(voting_list)
        processed_votings_ids = []
        voting_ids.each do |voting|
          next if Voting.exists?(voting)
          voting_html = Voting.create_voting(voting, statute_id)       #Vytvorenie hlasovania
          unless voting_html.nil?
            Vote.process_votes(voting_html,voting)                     #Priradenie hlasov poslancom, z daneho hlasovania
            processed_votings_ids << voting
          end  
        end
        Deputy.add_voting_relations_list_2(processed_votings_ids) unless processed_votings_ids.empty?    #Uprava zhody poslancov pre nove hlasovania
        break if statute.parent_id.nil?
        statute_id = statute.parent_id
      end
    end
  end

end