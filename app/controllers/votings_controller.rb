class VotingsController < ApplicationController
  # GET /votings
  # GET /votings.xml
  def index
    @title = "Hlasovania"
    @votings = Voting.all(:order => "popularity DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @votings }
    end
  end

  # GET /votings/1
  # GET /votings/1.xml
  def show
    @title = "Hlasovania"    
    @voting = Voting.find(params[:id])
    @votes = @voting.votes.all(:include => :deputy, :order => "vote")

    @user_vote = @voting.user_votes.find_or_initialize_by_user_id(current_user.id) if current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @voting }
    end
  end

  def vote
    if ( (@user = current_user) )
      @voting = Voting.find(params[:id])

      user_vote = UserVote.find(:first, :conditions => ["voting_id = ? and user_id = ?", @voting.id , @user.id])

      if user_vote.nil?
         user_vote = UserVote.new(:user_id => @user.id, :voting_id => @voting.id)
         old_vote = nil
      else
         old_vote = user_vote.vote
      end

#      user_vote = @voting.user_votes.find_or_initialize_by_user_id(@user.id)
      user_vote.vote = params[:my_vote]
#      user_vote.voting = @voting
#      user_vote.user = @user
      unless user_vote.save
         flash[:error] = "Chyba pri hlasovani."
         redirect_to @voting
         return
      end

      unless old_vote.nil?
        @user.add_voting_relations(params[:id], old_vote)
      else
        @user.add_voting_relations(params[:id])
      end

      flash[:notice] = "Vase hlasovanie bolo uspesne: " + params[:my_vote]
      redirect_to @voting
    end
  end

end
