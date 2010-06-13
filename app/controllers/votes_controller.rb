class VotesController < ApplicationController

  def vote
    #V pripade ze sa hlasuje z Navrhov zakonov.
    voting = Voting.find(:last, :conditions => ["statute_id = ?",params[:statute]]) unless params[:statute].nil?
    #Hlasovanie o konkretnom hlasovani.
    voting = Voting.find(params[:voting]) unless params[:voting].nil?

      user_vote = UserVote.find(:first, :conditions => ["voting_id = ? and user_id = ?", voting.id , current_user.id])

      if user_vote.nil?
         user_vote = UserVote.new(:user_id => current_user.id, :voting_id => voting.id)
         old_vote = nil
      else
         old_vote = user_vote.vote   #old_vote v pripade ze pouzivatel uz za dany zakon hlasoval
      end

      user_vote.vote = params[:my_vote]

      unless user_vote.save
         flash[:error] = "Chyba pri hlasovani."
         redirect_back_or voting
         return
      end

        unless old_vote.nil?
          current_user.add_voting_relations(voting.id, old_vote)
        else
          current_user.add_voting_relations(voting.id)
        end

      back = request.env["HTTP_REFERER"]
      flash[:success] = "Vase hlasovanie bolo uspesne: " + params[:my_vote]
      redirect_to(:controller => "votings", :action => "show", :id => voting.id, :path => back, :anchor => "result")
  end

end
