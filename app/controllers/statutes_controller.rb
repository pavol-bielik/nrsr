class StatutesController < ApplicationController
  before_filter :require_user, :only => [:vote]

  def index
    @title = "Návrhy zákonov"

    @statutes = Statute.search(params[:page], params[:statute_type])

    #Hlasovanie za zakony
    if current_user

      votings_ids = []
      @statutes.each do |statute|
        votings_ids << statute.votings.last.id
      end

      votes = UserVote.all(:conditions => ["user_id = ? AND voting_id IN (?)",current_user.id, votings_ids])

      @user_votes = {}
      votes.each do |vote|
        @user_votes[vote.voting_id] = vote
      end
    end

    #Moznosti pre zobrazenie zakonov
    @types = Statute.all(:select => "DISTINCT(statute_type)")

    @options = "<option>Všetky</option>"
    @types.each do |value|
       @options << "<option>#{value.statute_type}</option>"
    end

    @options.gsub!(">#{params[:statute_type]}", " selected='selected'>#{params[:statute_type]}" ) unless params[:statute_type].nil?


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @statutes }
    end
  end

  # GET /statutes/1
  # GET /statutes/1.xml
  def show
    @statute = Statute.find(params[:id])
    @votings = Voting.find(:all, :conditions => ["statute_id = ?", @statute.id], :order => "popularity DESC")

    @parent = Statute.find(@statute.parent_id) unless @statute.parent_id.nil?

    if current_user

      votings_ids = []
      @votings.each do |voting|
        votings_ids << voting.id
      end

      votes = UserVote.all(:conditions => ["user_id = ? AND voting_id IN (?)",current_user.id, votings_ids])

      @user_votes = {}
      votes.each do |vote|
        @user_votes[vote.voting_id] = vote
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @statute }
    end
  end

end
