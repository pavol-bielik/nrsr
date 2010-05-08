namespace :load do

  desc "Create deputies"
  task(:deputies_create => :environment) do
    Deputy.create_deputies
  end

  desc "Create statute with dependecies"
  task(:statute_create_with_dependecies => :environment) do
    statute_id = 1526
    while true do
      statute = Statute.create_or_update(statute_id)
      break if statute.nil?
      voting_list = Connector.download_statute_votings_list_html(statute_id)
      break if voting_list.nil?
      voting_ids = Extractor.extract_voting_ids(voting_list)
      voting_ids.each do |voting|
        voting_html = Voting.create_voting(voting, statute_id)
        Vote.process_votes(voting_html,voting)
      end
      break if statute.parent_id.nil?
      statute_id = statute.parent_id
    end  
  end

end