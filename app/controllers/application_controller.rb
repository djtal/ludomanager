# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  
  helper :all
  include AuthenticatedSystem
  include HoptoadNotifier::Catcher
  protect_from_forgery
  filter_parameter_logging :password
  
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  before_filter :set_section
  before_filter :set_timezone
  before_filter :get_account_games, :if => :logged_in?
  
  
  
  
  def self.subnav(submenu)
    cattr_accessor :subnav
    if submenu.to_s != controller_name
      self.subnav = "#{submenu}/subnav"
    else
      self.subnav = "subnav"
    end
  end
  
  protected
  
  
  def get_account_games
    @account_games = current_account.account_games.all
  end
  
  def set_section
    @section = :games
  end
  
  def set_timezone
    Time.zone = 'Paris'
  end
  
  
end