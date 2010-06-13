class DeputiesController < ApplicationController
  before_filter :require_user, :only => [:comparison]

  def index
    @title = "Poslanci"

    @options = "<option>Všetky</option>"

    unless params[:party].nil? or params[:party] == "Všetky"
      @deputies = Deputy.all(:conditions => ["party = ?", params[:party]]) 
    else
      @deputies = Deputy.all
    end

    @parties = Deputy.all(:select => "DISTINCT(party)")

    @parties.each do |deputy|
       @options << "<option>#{deputy.party}</option>"
    end

    @options.gsub!(">#{params[:party]}", " selected='selected'>#{params[:party]}" ) unless params[:party].nil?    

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deputies }
    end
  end

  def show

    @deputy = Deputy.find(params[:id])
    @title = "Poslanec | " + @deputy.firstname + " " + @deputy.lastname

    @datasets = datasets_for_comparison(nil, @deputy)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @deputy }
    end
  end

  def comparison
    #Porovanie jednotlivych hlasovani medzi poslancom a pouzivatelom

    @deputy = Deputy.find(params[:id])
    @user = @current_user
    @title = "Poslanec | " + @deputy.firstname + " " + @deputy.lastname

    @user_votes = UserVote.find(:all, :include => :voting, :conditions => ["user_id = ?", @user.id], :order => "vote DESC")
    @relation = UserRelation.find(:first, :conditions => ["user_id = ? and deputy_id = ?", @user.id, @deputy.id])

    vote_ids = []
    @user_votes.each do |vote|
      vote_ids << vote.voting_id
    end

    votes = Vote.find(:all, :conditions => ["deputy_id = ? and voting_id IN (?)",@deputy.id ,vote_ids] )

    @deputy_votes = {}

    votes.each do |vote|
      @deputy_votes[vote.voting_id] = vote.vote
    end

  end


end
