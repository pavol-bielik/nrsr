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
    @sdku_deputies = "["
    @smer_deputies = "["
    @sns_deputies = "["
    @hzds_deputies = "["
    @smk_deputies = "["
    @kdh_deputies = "["
    @ticks = "["

#    @deputies = "["

    i = @relations.length
    len = @relations.length + 1
    @relations.each do |relation|
      value = ((relation.relation*10)/relation.votes).round
      case Deputy::PARTY[relation.deputy2.party]
        when 1
          @sdku << "[#{value},#{i}],"
          @sdku_deputies << "[#{value},\"#{relation.deputy2.photo}\",\"#{relation.deputy2.degree}\",\"#{relation.deputy2.firstname}\",\"#{relation.deputy2.lastname}\",\"#{relation.deputy2.party}\"],"
        when 2
          @smer << "[#{value},#{i}],"
          @smer_deputies << "[#{value},\"#{relation.deputy2.photo}\",\"#{relation.deputy2.degree}\",\"#{relation.deputy2.firstname}\",\"#{relation.deputy2.lastname}\",\"#{relation.deputy2.party}\"],"
        when 3
          @sns << "[#{value},#{i}],"
          @sns_deputies << "[#{value},\"#{relation.deputy2.photo}\",\"#{relation.deputy2.degree}\",\"#{relation.deputy2.firstname}\",\"#{relation.deputy2.lastname}\",\"#{relation.deputy2.party}\"],"
        when 4
          @smk << "[#{value},#{i}],"
          @smk_deputies << "[#{value},\"#{relation.deputy2.photo}\",\"#{relation.deputy2.degree}\",\"#{relation.deputy2.firstname}\",\"#{relation.deputy2.lastname}\",\"#{relation.deputy2.party}\"],"
        when 5
          @hzds << "[#{value},#{i}],"
          @hzds_deputies << "[#{value},\"#{relation.deputy2.photo}\",\"#{relation.deputy2.degree}\",\"#{relation.deputy2.firstname}\",\"#{relation.deputy2.lastname}\",\"#{relation.deputy2.party}\"],"
        when 6
          @kdh << "[#{value},#{i}],"
          @kdh_deputies << "[#{value},\"#{relation.deputy2.photo}\",\"#{relation.deputy2.degree}\",\"#{relation.deputy2.firstname}\",\"#{relation.deputy2.lastname}\",\"#{relation.deputy2.party}\"],"
      end
#      @deputies << "[\"#{relation.deputy2.photo}\",\"#{relation.deputy2.degree}\",\"#{relation.deputy2.firstname}\",\"#{relation.deputy2.lastname}\",\"#{relation.deputy2.party}\"],"
       @ticks << "[#{i + 0.5},\"#{relation.deputy2.firstname} #{relation.deputy2.lastname}, #{ len - i}\"],"
       i -= 1
    end

    @sdku.chop!
    @sdku_deputies.chop!
    @smer.chop!
    @smer_deputies.chop!
    @sns.chop!
    @sns_deputies.chop!
    @hzds.chop!
    @hzds_deputies.chop!
    @smk.chop!
    @smk_deputies.chop!
    @kdh.chop!
    @kdh_deputies.chop!
    @ticks.chop!
#    @deputies.chop!
#    @deputies << "]"
    @ticks << "]"
    @sdku << "]"
    @sdku_deputies << "]"
    @smer << "]"
    @smer_deputies << "]"
    @sns << "]"
    @sns_deputies << "]"
    @hzds << "]"
    @hzds_deputies << "]"
    @smk << "]"
    @smk_deputies << "]"
    @kdh << "]"
    @kdh_deputies << "]"

    @datasets = "{
      'SMER – SD': {
            label: 'SMER – SD',
            data: #{@smer},
            deputies: #{@smer_deputies}
      },
      'SDKÚ – DS': {
            label: 'SDKÚ – DS',
            data: #{@sdku},
            deputies: #{@sdku_deputies}
      },
      'SNS': {
            label: 'SNS',
            data: #{@sns},
            deputies: #{@sns_deputies}
      },
      'SMK – MKP': {
            label: 'SMK – MKP',
            data: #{@smk},
            deputies: #{@smk_deputies}
      },
      'ĽS – HZDS': {
            label: 'ĽS – HZDS',
            data: #{@hzds},
            deputies: #{@hzds_deputies}
      },
      'KDH': {
            label: 'KDH',
            data: #{@kdh},
            deputies: #{@kdh_deputies}
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
