class StatutesController < ApplicationController
  # GET /statutes
  # GET /statutes.xml

  def vote
    if ( (@user = current_user) )
      @voting = Voting.find(:last, :conditions => ["statute_id = ?",params[:id]])

      user_vote = UserVote.find(:first, :conditions => ["voting_id = ? and user_id = ?", @voting.id , @user.id])

      if user_vote.nil?
         user_vote = UserVote.new(:user_id => @user.id, :voting_id => @voting.id)
         old_vote = nil
      else
         old_vote = user_vote.vote
      end

      user_vote.vote = params[:my_vote]

      unless user_vote.save
         flash[:error] = "Chyba pri hlasovani."
         redirect_back_or @voting
         return
      end

#      unless (user_vote.vote == "?" and old_vote.nil?)
        unless old_vote.nil?
          @user.add_voting_relations(@voting.id, old_vote)
        else
          @user.add_voting_relations(@voting.id)
        end
#      end

      @back = request.env["HTTP_REFERER"]
      flash[:success] = "Vase hlasovanie bolo uspesne: " + params[:my_vote]
      redirect_to(:controller => "votings", :action => "show", :id => @voting.id, :path => @back, :anchor => "result")
    end

  end
  
  def index
    @title = "Návrhy zákonov"

#    unless params[:statute_type].nil? or params[:statute_type] == "Všetky"
#      @statutes = Statute.all(:conditions => ["statute_type = ?", params[:statute_type]])
#    else
#      @statutes = Statute.all
#    end
    @statutes = Statute.search(params[:page], params[:statute_type])


    @user_votes = {}
    @statutes.each do |statute|
      @user_votes[statute.id] = statute.votings.last.user_votes.find_or_initialize_by_user_id(current_user.id) if current_user 
    end

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

    @user_votes = {}
    @votings.each do |voting|
      @user_votes[voting.id] = voting.user_votes.find_or_initialize_by_user_id(current_user.id) if current_user
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @statute }
    end
  end

end
