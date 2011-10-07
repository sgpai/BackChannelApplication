class UsersController < ApplicationController
  # GET /users
  # GET /users.json
  before_filter :authorize, :except => [:new, :create]
  def index
    if(session[:loginType]=='admin')
      @users = User.all

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @users }
      end
    else
      flash[:notice] = "Access denied."
      redirect_to users_notauthorized_path
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if(params[:id].to_s() == User.find_by_userName(session[:userName]).id.to_s())
      @user = User.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @user }
      end
    else
      flash[:notice] = "Access denied."
      redirect_to users_notauthorized_path
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    p 'new called'
    @user = User.new

    p "#{@user}"
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        if(session[:loginType]=='admin')
          @adminUser = User.find_by_userName(session[:userName])
          format.html { redirect_to @adminUser, notice: "User #{@user.userName} was successfully created."}
          format.json { render json: @adminUser, status: :created, location: @adminUser }
        elsif(session[:loginType].nil?)
          format.html { redirect_to @user, notice: "User #{@user.userName} was successfully created."}
          format.json { render json: @user, status: :created, location: @user }
          session[:userName] = @user.userName
          session[:loginType] =  @user.loginType
        end

      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        session[:userName] = @user.userName
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    @deletedUser = User.find_by_userName("UserDeleted")
    @postOfDeletedUser = Post.find(:all, :conditions => ["user_id = ?", @user.id])

    #updating the user_id of all the posts of the deleted user to a default user "UserDeleted"
    @postOfDeletedUser.each do
      |post|
      post.update_attribute("user_id",@deletedUser.id)
    end

    @votesOfDeletedUser = Post.find(:all, :conditions => ["user_id = ?", @user.id])

    #updating the user_id of all the votes of the deleted user to a default user "UserDeleted"
    @votesOfDeletedUser.each do
      |vote|
      vote.update_attribute("user_id", @deletedUser.id)
    end

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end

  def showaccountdetails
    p "params #{params[:id]}"
    flash[:notice] = "Details for the user #{session[:userName]} are:\n"
    @user = User.find_by_userName(session[:userName])
  end
end
