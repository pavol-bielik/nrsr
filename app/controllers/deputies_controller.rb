class DeputiesController < ApplicationController
  auto_complete_for :deputy, :lastname

  # GET /deputies
  # GET /deputies.xml
  def index
    @title = "Poslanci"

    @options = "<option>Všetky</option>
                <option>SDKÚ – DS</option>
                <option>SMER – SD</option>
                <option>SNS</option>
                <option>SMK – MKP</option>
                <option>ĽS – HZDS</option>
                <option>KDH</option>"

    @options.gsub!(">#{params[:party]}", " selected='selected'>#{params[:party]}" ) unless params[:party].nil?

    unless params[:party].nil? or params[:party] == "Všetky"
      @deputies = Deputy.all(:conditions => ["party = ?", params[:party]]) 
    else
      @deputies = Deputy.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deputies }
    end
  end

  # GET /deputies/1
  # GET /deputies/1.xml
  def show

#    @options = "<option>Všetky</option>
#                <option>SDKÚ – DS</option>
#                <option>SMER – SD</option>
#                <option>SNS</option>
#                <option>SMK – MKP</option>
#                <option>ĽS – HZDS</option>
#                <option>KDH</option>"
#
#    @options.gsub!(">#{params[:party]}", " selected='selected'>#{params[:party]}" ) unless params[:party].nil?
#
#    @deputies = Deputy.all
#    @deputy_options = ""
#    @deputies.each do |dep|
#      @deputy_options << "<option>#{dep.firstname} #{dep.lastname}</option>"
#    end
#
#    @deputy_options.gsub!(">#{params[:deputy]}", " selected='selected'>#{params[:deputy]}" ) unless params[:deputy].nil?

    @deputy = Deputy.find(params[:id])
    @title = "Poslanec | " + @deputy.firstname + " " + @deputy.lastname

    @relations = DeputyRelation.find(:all, :include => :deputy2, :conditions => ["deputy1_id = ?", @deputy.id], :order => "relation DESC")

    @data = "[]"

    @sdku = "["
    @smer = "["
    @sns = "["
    @hzds = "["
    @smk = "["
    @kdh = "["

    @deputies = "["

    i = 0
    @relations.each do |relation|
      case Deputy::PARTY[relation.deputy2.party]
        when 1
          @sdku << "[#{i},#{((relation.relation*10)/relation.votes).round}],"
        when 2
          @smer << "[#{i},#{((relation.relation*10)/relation.votes).round}],"
        when 3
          @sns << "[#{i},#{((relation.relation*10)/relation.votes).round}],"
        when 4
          @smk << "[#{i},#{((relation.relation*10)/relation.votes).round}],"
        when 5
          @hzds << "[#{i},#{((relation.relation*10)/relation.votes).round}],"
        when 6
          @kdh << "[#{i},#{((relation.relation*10)/relation.votes).round}],"
      end
      @deputies << "[\"#{relation.deputy2.photo}\",\"#{relation.deputy2.degree}\",\"#{relation.deputy2.firstname}\",\"#{relation.deputy2.lastname}\",\"#{relation.deputy2.party}\"],"
       i += 1
    end

    @sdku.chop!
    @smer.chop!
    @sns.chop!
    @hzds.chop!
    @smk.chop!
    @kdh.chop!
    @deputies.chop!
    @deputies << "]"
    @sdku << "]"
    @smer << "]"
    @sns << "]"
    @hzds << "]"
    @smk << "]"
    @kdh << "]"

    @datasets = "{
      'SMER – SD': {
            label: 'SMER – SD',
            data: #{@smer}
      },
      'SDKÚ – DS': {
            label: 'SDKÚ – DS',
            data: #{@sdku}
      },
      'SNS': {
            label: 'SNS',
            data: #{@sns}
      },
      'SMK – MKP': {
            label: 'SMK – MKP',
            data: #{@smk}
      },
      'ĽS – HZDS': {
            label: 'ĽS – HZDS',
            data: #{@hzds}
      },
      'KDH': {
            label: 'KDH',
            data: #{@kdh}
      }
}"
#    @data.chop!
#    @data << "]"

#    unless params[:party].nil? or params[:party] == "Všetky"
#      relations = DeputyRelation.find(:all, :include => :deputy2, :conditions => ["deputy1_id = ? AND `deputies`.party = ?", @deputy.id, params[:party]], :order => "relation DESC")
#    else
#      relations = DeputyRelation.find(:all, :include => :deputy2, :conditions => ["deputy1_id = ?", @deputy.id], :order => "relation DESC")
#    end
#
#    has_been = nil
#    re = /([^ ]*) (.*)/
#    unless params[:deputy].nil?
#      match = params[:deputy].match(re)
#      search_deputy = Deputy.find(:first,:conditions => ["firstname = ? AND lastname = ?", match[1], match[2]])
#    else
#      search_deputy = nil
#    end
#
#    @chart = "<script type='text/javascript' src='http://www.google.com/jsapi'></script>
#    <script type='text/javascript'>
#      google.load('visualization', '1', {packages:['columnchart']});
#      google.setOnLoadCallback(drawChart);
#      var chart;
#      function drawChart() {
#        var data = new google.visualization.DataTable();
#        data.addColumn('string', 'Year');
#        data.addColumn('number', 'SDKÚ – DS');
#        data.addColumn('number', 'SMER – SD');
#        data.addColumn('number', 'SNS');
#        data.addColumn('number', 'SMK – MKP');
#        data.addColumn('number', 'ĽS – HZDS');
#        data.addColumn('number', 'KDH');
#        data.addRows(11);"
#
#      0.upto(4) do |x|
#        relation = relations[x]
#        if (!search_deputy.nil? and search_deputy == relation.deputy2)
#          has_been = 1
#          info = "
#          data.setValue(#{x}, 0, '>> #{relation.deputy2.firstname} #{relation.deputy2.lastname} << #{x+1}.');
#          data.setValue(#{x}, #{Deputy::PARTY[relation.deputy2.party]}, #{((relation.relation*10)/relation.votes).round});"
#        else
#          info = "
#          data.setValue(#{x}, 0, '#{relation.deputy2.firstname} #{relation.deputy2.lastname} #{x+1}.');
#          data.setValue(#{x}, #{Deputy::PARTY[relation.deputy2.party]}, #{((relation.relation*10)/relation.votes).round});"
#        end
#        @chart << info
#      end
#
#    len = relations.length - 1
#
#     i = 10
#    len.downto(len-4) do |x|
#        relation = relations[x]
#        if (!search_deputy.nil? and search_deputy == relation.deputy2)
#          has_been = 1
#          info = "
#          data.setValue(#{i}, 0, '>> #{relation.deputy2.firstname} #{relation.deputy2.lastname} << #{x+1}.');
#          data.setValue(#{i}, #{Deputy::PARTY[relation.deputy2.party]}, #{((relation.relation*10)/relation.votes).round});"
#        else
#          info = "
#          data.setValue(#{i}, 0, '#{relation.deputy2.firstname} #{relation.deputy2.lastname} #{x+1}.');
#          data.setValue(#{i}, #{Deputy::PARTY[relation.deputy2.party]}, #{((relation.relation*10)/relation.votes).round});"
#        end
#        @chart << info
#        i -= 1
#    end
#
#    unless has_been or search_deputy.nil?
#      position = relations.index(search_deputy.id)
#      relation = relations[position]
#      info = "
#      data.setValue(5, 0, '>> #{relation.deputy2.firstname} #{relation.deputy2.lastname} << #{position+1}.');
#      data.setValue(5, #{Deputy::PARTY[relation.deputy2.party]}, #{((relation.relation*10)/relation.votes).round});"
#      @chart << info
#    end
#
#
#  last = "
#  chart = new google.visualization.BarChart(document.getElementById('chart_div'));
#  chart.draw(data, {is3D: true, legendFontSize: 12, min: 0, max: 100, isStacked: true, width: 500, height: 495})
#  google.visualization.events.addListener(chart, 'select', selectHandler);
#}
#
#function selectHandler() {
#  var selection = chart.getSelection();
#  var message = '';
#  if (message == '') {
#    message = 'nothing';
#  }
#  alert('You selected ' + message);
#}
#   </script>
#"
#    @chart << last

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @deputy }
    end
  end


end
