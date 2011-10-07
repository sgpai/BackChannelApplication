class ApplicationController < ActionController::Base

  before_filter :removeCache

  #removeCache is implemented to stop browser stop caching of application pages
  def removeCache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
  end

  private
  #method to authorize the access to any page in the application
  def authorize
    unless User.find_by_userName(session[:userName])
      flash[:notice] = "Please log in"
      redirect_to(:controller => "logins" , :action => "index" )
    end
  end
end
