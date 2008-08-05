# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  helper :all
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  before_filter :set_section
  before_filter :set_path
  before_filter :get_account_games, :if => :logged_in?
  
  
  
  def rescue_action_in_public(exception)
    case exception
    when ::ActionController::UnknownAction, ::ActionController::RoutingError
      render :file => File.join("#{RAILS_ROOT}", "public", "404.rhtml"), :layout => true, :status => "404 not found"
    else
      render :file => File.join("#{RAILS_ROOT}", "public", "500.rhtml"), :layout => true, :status => "500 error"
    end
  end
  
  protected
  
  def get_account_games
    @account_games = current_account.account_games.all
  end
  
  def set_section
    @section = :games
  end
  
  def set_path
    @path = [@section]
  end
end