require "application_responder"

# encoding: UTF-8

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  # rescue_from ActiveRecord::RecordNotFound, with: :not_found
  # include AuthenticatedSystem
  protect_from_forgery with: :exception

  # If you want "remember me" functionality, add this before_filter to Application Controller
  # before_filter :login_from_cookie
  before_filter :set_section
  before_filter :set_timezone
  before_filter :get_account_games, if: :logged_in?

  # Until we migrate to devise
  def current_account
    Account.first
  end

  def logged_in?
    true
  end

  def login_required
    true
  end

  helper_method :logged_in?, :current_account




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
