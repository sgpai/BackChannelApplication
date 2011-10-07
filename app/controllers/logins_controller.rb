 class LoginsController < ApplicationController

  #initialize the session
  def index
    #check if the user is in session
    #if yes, redirect to the user's home page
     if((!session[:userName].nil?) && (!session[:loginType].nil?))
       redirect_to User.find_by_userName(session[:userName])
    #redirect to the login page
     else
       @checkAdminUser = User.find_by_userName("csc517admin")
       if(@checkAdminUser.nil?)
         p "admin user not present"
         @adminUser = User.new(:userName => "csc517admin",:password => "csc517admin",:loginType => "admin",:email => "admin@csc517.edu")
         @adminUser.save
       end

       @checkAnonymousUser = User.find_by_userName("UserDeleted")
       if(@checkAnonymousUser.nil?)
         p "anonymous user not present"
         @anonymousUser = User.new(:userName => "UserDeleted",:password => "delete",:loginType => "admin",:email => "delete@csc517.edu")
         @anonymousUser.save
       end

      session[:userName] = nil
      session[:loginType] = nil
    end
  end

  #method to authenticate the user and redirect to appropriate user home pages depending on the login type
  def authenticate()

    #check for correct input entry
    if(params[:userName].nil? || params[:password].nil?) #redirect to login page
      flash[:notice] = "Enter both user name and password."
      redirect_to(:controller => "logins", :action => "index")

    else #check the user database for correct username/password combination
      @user = User.find(:all,:conditions => ["userName = ? and password = ?", params[:userName], params[:password]])[0]

      #no match, redirect to login page
      if(@user == nil)
        flash[:notice] = "Incorrect login credentials. Please try again."
        redirect_to(:controller => "logins", :action => "index")

      #if matched, redirect to appropriate user page
      else
          session[:userName] = @user.userName
          session[:loginType] = @user.loginType
          redirect_to(@user)
      end
    end
  end

  def new
  end

  #calls authenticate everytime page loads
  def create
    authenticate()
  end

  #logout
  def signout
    session[:userName]=nil
    session[:loginType]=nil
    flash[:alert] = "You have successfully signed out."
  end
end