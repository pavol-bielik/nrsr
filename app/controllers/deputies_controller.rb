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

    hash = {}
    dep_options = []
    @ticks = "["

    i = @relations.length
    len = @relations.length + 1
    @relations.each do |relation|
      value = ((relation.relation*10)/relation.votes).round
      hash[relation.deputy2.party] = [ 0 ] if hash[relation.deputy2.party].nil?
      hash[relation.deputy2.party] << [value, i, relation.deputy2.photo, relation.deputy2.degree, relation.deputy2.firstname, relation.deputy2.lastname, relation.deputy2.party]
      hash[relation.deputy2.party][0] += value
      dep_options << ["#{i}", "#{relation.deputy2.lastname}, #{relation.deputy2.firstname}"]
       @ticks << "[#{i + 0.5},'<a style=\"font-size:14px;\" href=\"/deputies/#{relation.deputy2.id}\">#{relation.deputy2.firstname} #{relation.deputy2.lastname}</a>, #{ len - i}'],"
       i -= 1
    end

    @ticks.chop!
    @ticks << "]"

    dep_options.sort! {|x ,y| x[1] <=> y[1]}
    @options = ""
    dep_options.each do |element|
      @options << "<option id=\"#{element[0]}\">#{element[1]}</option>"
    end

    avg_relations = []
    hash.each do |key, value|
      len = hash[key].length
      avg_relations << [key, value[0]/len]
    end

   avg_relations.sort! {|x,y| y[1] <=> x[1]}

    i = 1
    @avgticks = "["
    @avgpartydatasets = "{"
    avg_relations.each do |element|
        @avgpartydatasets << "
        '#{element[0]}': {
          label: '#{element[0]}', data: [[#{i - 0.4}, #{element[1]}]]
          },"
        @avgticks << "[#{i},'#{element[0]}'],"
      i += 1
    end
    @avgpartydatasets.chop!
    @avgticks.chop!
    @avgpartydatasets << "}"
    @avgticks << "]"


    @datasets = "{"
#    @partydatasets = "{"
#    max = 60.0
    hash.each do |key, value|
      i = 1
#      len = hash[key].length
      data = "["
      deputies = "["
#      partydata = "["
      value.each do |element|
        if i == 1
          i += 1
          next
        end
#        unless i == 2
#          partydata << "[#{(max/len*i).round}, #{element[0]}],"
#        else
#          partydata << "[0, #{element[0]}],"
#        end
        data << "[#{element[0]}, #{element[1]}],"
        deputies << "[#{element[1]}, '#{element[2]}','#{element[3]}', '#{element[4]}', '#{element[5]}', '#{element[6]}'],"
         i += 1
      end
      data.chop!
      deputies.chop!
#      partydata.chop!
      data << "]"
      deputies << "]"
#      partydata << "]"
#      @partydatasets << "
#          '#{key}': {
#          label: '#{key}',
#          data: #{partydata}
#          },"
      @datasets << "
          '#{key}': {
          label: '#{key}',
          data: #{data},
          deputies: #{deputies}
          },"
    end
#    @partydatasets.chop!
    @datasets.chop!
#    @partydatasets << "}"
    @datasets << "}"


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
