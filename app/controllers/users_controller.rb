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
      redirect_back_or account_url
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

    relations = UserRelation.find(:first, :conditions => ["user_id = ?", @user.id], :order => "relation DESC")

    unless relations.votes == 0     #Pouzivatel este nehlasoval
      @datasets = datasets_for_comparison(@user, nil)
    else
      @datasets = nil
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

