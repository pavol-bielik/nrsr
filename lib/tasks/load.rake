namespace :load do

  desc "Create deputies"
  task(:deputies_create => :environment) do
    Deputy.create_deputies
  end

  desc "Create new statutes with dependecies"
  task(:create_new_statutes_with_dependecies => :environment) do
    last_statute_html = Connector.download_last_statute_html
    last_statute_id = Extractor.extract_last_statute_id(last_statute_html)
    return if last_statute_id.nil?
    maximum_statute_id = Statute.maximum('id')

    (maximum_statute_id + 1).upto(last_statute_id) do |statute_id|
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

end