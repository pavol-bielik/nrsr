class StatutesController < ApplicationController
  # GET /statutes
  # GET /statutes.xml
  def index
    @title = "Návrhy zákonov"

#    unless params[:statute_type].nil? or params[:statute_type] == "Všetky"
#      @statutes = Statute.all(:conditions => ["statute_type = ?", params[:statute_type]])
#    else
#      @statutes = Statute.all
#    end
    @statutes = Statute.search(params[:page], params[:statute_type])

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

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @statute }
    end
  end

end
