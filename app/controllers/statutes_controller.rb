class StatutesController < ApplicationController
  # GET /statutes
  # GET /statutes.xml
  def index
    #@statutes = Statute.all
    @statutes = Statute.find(:all, :conditions => "state <> 'Evidencia'")

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

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @statute }
    end
  end

end
