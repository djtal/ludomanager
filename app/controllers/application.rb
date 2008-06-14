# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  before_filter :set_section
  before_filter :set_path
  
  
  
  def rescue_action_in_public(exception)
    case exception
    when ::ActionController::UnknownAction, ::ActionController::RoutingError
      render :file => File.join("#{RAILS_ROOT}", "public", "404.rhtml"), :layout => true, :status => "404 not found"
    else
      render :file => File.join("#{RAILS_ROOT}", "public", "500.rhtml"), :layout => true, :status => "500 error"
    end
  end
  
  protected
  
  def set_section
    @section = :games
  end
  
  def set_path
    @path = [@section]
  end
end