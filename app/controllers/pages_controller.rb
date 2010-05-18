class PagesController < ApplicationController
  def home
    @title = "Úvod"    
  end

  def how_to
    @title = "Navod"
  end

end
