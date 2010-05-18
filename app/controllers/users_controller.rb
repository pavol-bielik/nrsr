class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :similarities, :edit, :update]

  def new
    @user = User.new
  end

  def create
    if params[:type].nil?
      @user = User.new(params[:user])
    else
      last_guest = User.find(:last, :conditions => "login like 'guest%'")
      if last_guest.nil?
          id = 1
      else
          match = last_guest.login.match(/guest(\d+)/)
          id = match[1].to_i + 1
      end
      @user = User.new(:login => "guest#{id}", :password => "guest", :password_confirmation => "guest")
    end
    if @user.save  
      @user.create_relations
      flash[:success] = "Account registered!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end

  def show
    @user = @current_user
    @votes = UserVote.find(:all, :include => :voting, :conditions => ["user_id = ?", @user.id])
    @voting_count = @votes.count
  end

  def similarities
    @user = @current_user

    @relations = UserRelation.find(:all, :include => :deputy, :conditions => ["user_id = ?", @user.id], :order => "relation DESC")

    unless @relations.first.votes == 0
            hash = {}
      dep_options = []
      @ticks = "["

      i = @relations.length
      len = @relations.length + 1
      @relations.each do |relation|
        value = ((relation.relation*10)/relation.votes).round
        hash[relation.deputy.party] = [ 0 ] if hash[relation.deputy.party].nil?
        hash[relation.deputy.party] << [value, i, relation.deputy.id, relation.deputy.degree, relation.deputy.firstname, relation.deputy.lastname, relation.deputy.party]
        hash[relation.deputy.party][0] += value
        dep_options << ["#{i}", "#{relation.deputy.lastname}, #{relation.deputy.firstname}"]
         @ticks << "[#{i + 0.5},'<a style=\"font-size:150%;\" href=\"/deputies/#{relation.deputy.id}\">#{relation.deputy.firstname} #{relation.deputy.lastname}</a>, #{ len - i}'],"
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
      hash.each do |key, value|
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
        @datasets << "
            '#{key}': {
            label: '#{key}',
            data: #{data},
            deputies: #{deputies}
            },"
      end
      @datasets.chop!
      @datasets << "}"
    end  
  end

  def edit
    @user = @current_user
  end

  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
end

