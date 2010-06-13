class VotingsController < ApplicationController
  before_filter :require_user, :only => [:vote]

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

    #google chart ucasti poslancov na hlasovani
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

end
