class VotingsController < ApplicationController
  # GET /votings
  # GET /votings.xml
  def index
    @votings = Voting.all(:order => "popularity DESC")
    @count = Voting.count

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @votings }
    end
  end

  # GET /votings/1
  # GET /votings/1.xml
  def show
    @voting = Voting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @voting }
    end
  end

end
