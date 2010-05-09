class DeputiesController < ApplicationController
  # GET /deputies
  # GET /deputies.xml
  def index
    @deputies = Deputy.all(:order => "party")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deputies }
    end
  end

  # GET /deputies/1
  # GET /deputies/1.xml
  def show
    @deputy = Deputy.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @deputy }
    end
  end


end
