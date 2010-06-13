# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
helper :all
  helper_method :current_user_session, :current_user, :datasets_for_comparison
  filter_parameter_logging :password, :password_confirmation
  protect_from_forgery

  before_filter :site_init

  def site_init
    @site_root = ""
  end

  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end

    def require_user
      unless current_user
        store_location
        flash[:error] = "You must be logged in to access this page"
        redirect_to new_user_sessions_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:error] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def redirect_back_or(path)
      redirect_to :back
      rescue ActionController::RedirectBackError
      redirect_to path
    end

    def datasets_for_comparison(user = nil, deputy = nil)

      datasets = {}

      relations = DeputyRelation.find(:all, :include => :deputy_compare, :conditions => ["deputy1_id = ?", deputy.id], :order => "relation DESC") unless deputy.nil?
      relations = UserRelation.find(:all, :include => :deputy_compare, :conditions => ["user_id = ?", user.id], :order => "relation DESC") unless user.nil?

      parties = {}
      dep_options = []
      ticks = "["


      #Zbieranie dat pre graf
      #Vytvorenie Hash kde ako kluce su mena politickych stran
      #Kazdy zaznam v Hash tvory pole, ktoreho
        #prvy prvok je sucet zhod jednotlivych poslancov danej strany
        #druhy prvok je pole ktore ma tvar: [hodnota_zhody, poradie, id_poslanca, titul_poslanca, meno_poslanca, priezvisko_poslanca]

      #Vytvorenie ticks, ktore tvoria Y os grafu.
      #dep_options -> Vytvorenie zoznamu poslancov pre vyhladavanie v grafe

      i = relations.length
      len = relations.length + 1
      relations.each do |relation|
        value = ((relation.relation*10)/relation.votes).round
        parties[relation.deputy_compare.party] = [ 0 ] if parties[relation.deputy_compare.party].nil?
        parties[relation.deputy_compare.party] << [value, i, relation.deputy_compare.id, relation.deputy_compare.degree, relation.deputy_compare.firstname, relation.deputy_compare.lastname]
        parties[relation.deputy_compare.party][0] += value
        dep_options << ["#{i}", "#{relation.deputy_compare.lastname}, #{relation.deputy_compare.firstname}"]
         ticks << "[#{i + 0.5},'<a style=\"font-size:150%;\" href=\"/deputies/#{relation.deputy_compare.id}\">#{relation.deputy_compare.firstname} #{relation.deputy_compare.lastname}</a>, #{ len - i}'],"
         i -= 1
      end

      ticks.chop!
      ticks << "]"
      datasets["ticks"] = ticks


      dep_options.sort! {|x ,y| x[1] <=> y[1]}
      options = ""
      dep_options.each do |element|
        options << "<option id=\"#{element[0]}\">#{element[1]}</option>"
      end

      datasets["options"] = options

      avg_relations = []
      parties.each do |key, value|
        len = parties[key].length
        avg_relations << [key, value[0]/len]
      end

     avg_relations.sort! {|x,y| y[1] <=> x[1]}

      #Vytvorenie vstupnych dat pre graf zhody zo stranamy
      #Ukazkovy vystup:
      #avgpartydatasets: {
  #        'SMK – MKP': {
  #          label: 'SMK – MKP', data: [[0.6, 59]]
  #          },
  #        'SMER – SD': {
  #          label: 'SMER – SD', data: [[1.6, 53]]
  #          },
  #        'KDH': {
  #          label: 'KDH', data: [[2.6, 50]]
  #          },
  #        '¼S – HZDS': {
  #          label: '¼S – HZDS', data: [[3.6, 49]]
  #          },
  #        'SDKÚ – DS': {
  #          label: 'SDKÚ – DS', data: [[4.6, 49]]
  #          },
  #        'Nezávislý': {
  #          label: 'Nezávislý', data: [[5.6, 49]]
  #          },
  #        'SNS': {
  #          label: 'SNS', data: [[6.6, 45]]
  #          }}
      #avgticks: [[1,'SMK – MKP'],[2,'SMER – SD'],[3,'KDH'],[4,'¼S – HZDS'],[5,'SDKÚ – DS'],[6,'Nezávislý'],[7,'SNS']]

      i = 1
      avgticks = "["
      avgpartydatasets = "{"
      avg_relations.each do |element|
          avgpartydatasets << "
          '#{element[0]}': {
            label: '#{element[0]}', data: [[#{i - 0.4}, #{element[1]}]]
            },"
          avgticks << "[#{i},'#{element[0]}'],"
        i += 1
      end
      avgpartydatasets.chop!
      avgticks.chop!
      avgpartydatasets << "}"
      avgticks << "]"

      datasets["avgticks"] = avgticks
      datasets["avgpartydatasets"] = avgpartydatasets

      #Vytvorenie vstupnych dat pre zhodu s poslancami
      #datasets:
  #    {
  #    'Nezávislý': {
  #              label: 'Nezávislý',
  #              data: [[68, 145],[67, 142],[66, 141],[64, 138],[63, 135],[61, 132],[57, 120],[55, 75],[55, 74],[49, 24],[45, 15],[45, 13],[44, 11],[40, 8],[11, 1]],
  #              deputies: [[145, '281','Ing.', 'Juraj', 'Liška', 'Nezávislý'],[142, '669','Ing.', 'Martin', 'Kuruc', 'Nezávislý'],[141, '697','Ing.', 'Zsolt', 'Simon', 'Nezávislý'],[138, '96','PhDr.', 'László', 'Nagy', 'Nezávislý'],[135, '23','Ing.', 'Béla', 'Bugár', 'Nezávislý'],[132, '655','Ing.', 'Peter', 'Gabura', 'Nezávislý'],[120, '232','MUDr.', 'Tibor', 'Bastrnák', 'Nezávislý'],[75, '319','RNDr.', 'Pavol', 'Minárik', 'Nezávislý'],[74, '92','RNDr.', 'František', 'Mikloško', 'Nezávislý'],[24, '666','Ing.', 'Anton', 'Korba', 'Nezávislý'],[15, '13','RNDr.', 'Rudolf', 'Bauer', 'Nezávislý'],[13, '258','Mgr.', 'Gábor', 'Gál', 'Nezávislý'],[11, '318','Ing.', 'Tibor', 'Mikuš', 'Nezávislý'],[8, '102','doc. RNDr., CSc.', 'Vladimír', 'Palko', 'Nezávislý'],[1, '677','Mgr.', '¼uboš', 'Miche¾', 'Nezávislý']]
  #              },
  #    ...
  #  }
  #

      comparison_dataset = "{"
      parties.each do |key, value|
        i = 1
        data = "["
        deputies = "["
        value.each do |element|
          if i == 1
            i += 1
            next
          end
          data << "[#{element[0]}, #{element[1]}],"
          deputies << "[#{element[1]}, '#{element[2]}','#{element[3]}', '#{element[4]}', '#{element[5]}', '#{element[6]}'],"
           i += 1
        end
        data.chop!
        deputies.chop!
        data << "]"
        deputies << "]"

        comparison_dataset << "
            '#{key}': {
            label: '#{key}',
            data: #{data},
            deputies: #{deputies}
            },"
      end
      comparison_dataset.chop!
      comparison_dataset << "}"
      datasets["comparison_dataset"] = comparison_dataset

      return datasets

    end

end
