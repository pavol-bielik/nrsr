class StatutesController < ApplicationController
  # GET /statutes
  # GET /statutes.xml
  def index
    @statutes = Statute.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @statutes }
    end
  end

  # GET /statutes/1
  # GET /statutes/1.xml
  def show
    @statute = Statute.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @statute }
    end
  end

end
