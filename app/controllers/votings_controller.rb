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
    @votes = @voting.votes.all(:include => :deputy, :order => "vote DESC")

    @back = @back

    @user_vote = @voting.user_votes.find_or_initialize_by_user_id(current_user.id) if current_user

    @chart = "
<script type=\"text/javascript\" src=\"http://www.google.com/jsapi\"></script>
    <script type=\"text/javascript\">
      google.load(\"visualization\", \"1\", {packages:[\"corechart\"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Hlas');
        data.addColumn('number', 'Počet');
        data.addRows(5);
        data.setValue(0, 0, 'Za');
        data.setValue(0, 1, #{@voting.pro_count});
        data.setValue(1, 0, 'Proti');
        data.setValue(1, 1, #{@voting.against_count});
        data.setValue(2, 0, 'Zdržalo sa');
        data.setValue(2, 1, #{@voting.hold_count});
        data.setValue(3, 0, 'Nehlasovalo');
        data.setValue(3, 1, #{@voting.not_voting_count});
        data.setValue(4, 0, 'Neprítomní');
        data.setValue(4, 1, #{@voting.not_attending_count});

        var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
        chart.draw(data, {colors: ['green', 'red', 'orange', 'yellow', 'black'], width: 450, height: 230, title: 'Hlasovanie poslancov'});
      }
    </script>
"

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

      user_vote.vote = params[:my_vote]
      unless user_vote.save
         flash[:error] = "Chyba pri hlasovani."
         redirect_back_or @voting
         return
      end

#      unless (user_vote.vote == "?" and old_vote.nil?)
        unless old_vote.nil?
          @user.add_voting_relations(params[:id], old_vote)
        else
          @user.add_voting_relations(params[:id])
        end
#      end

      @back = request.env["HTTP_REFERER"]
      flash[:success] = "Vase hlasovanie bolo uspesne: " + params[:my_vote]
      redirect_to(:controller => "votings", :action => "show", :id => @voting.id, :path => @back, :anchor => "result")
    end
  end

end
