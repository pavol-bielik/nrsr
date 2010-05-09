# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

    def title
      return "Volby" unless defined?(@title)
      @title
    end

end
