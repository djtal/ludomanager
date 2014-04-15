# # encoding: UTF-8
# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  helper :all
  include AuthenticatedSystem
  protect_from_forgery
  filter_parameter_logging :password

  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie
  before_filter :set_section
  before_filter :set_timezone
  before_filter :get_account_games, if: :logged_in?




  def self.subnav(submenu)
    cattr_accessor :subnav
    if submenu.to_s != controller_name
      self.subnav = "#{submenu}/subnav"
    else
      self.subnav = "subnav"
    end
  end


  protected

  def not_found
    respond_to do |format|
      format.html { render template: 'shared/not_found' }
    end
  end

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
